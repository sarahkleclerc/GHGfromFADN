#' Predict INUSE_Q: quantity of N in mineral fertilisers mineral input
#'
#' @description
#' INUSE_Q\_pred is a calculated variable that takes the value of INUSE_Q
#' from 2017 when available and otherwise a value deducted from the fertiliser
#' expenditure. By default, INUSE = 0 for organic and converting farms.
#'
#' @usage predict_inuse(data, null_org = TRUE)
#'
#' @param data A dataframe with the following variables: COUNTRY, YEAR, ORGANIC, SE025, SE295, SE296 or INUSE_Q
#' @param null_org TRUE to set INUSE = 0 for organic and converting farms, default.
#' FALSE to predict values even for organic and converting farms.
#'
#' @return A dataframe with INUSE_Q_pred expressed in tons and INUSE_Q_pred_kg in kg.
#'
#' @import rlang
#' @import dplyr
#'
#' @export

predict_inuse <- function(data, null_org = TRUE){

  # 0- Tests -------------------------------------------------------------------
  if(is.data.frame(data) == FALSE)
    stop("data must be a data frame")
  if(has_name(data, "COUNTRY") == FALSE)
    stop(paste0(" COUNTRY does not exist in data and is mandatory"))
  if(has_name(data, "YEAR") == FALSE)
    stop(paste0(" YEAR does not exist in data and is mandatory"))
  if(has_name(data, "ORGANIC") == FALSE)
    stop(paste0(" ORGANIC does not exist in data and is mandatory"))
  if(has_name(data, "SE025") == FALSE)
    stop(paste0(" SE025 does not exist in data and is mandatory"))
  if(has_name(data, "SE295") == FALSE)
    stop(paste0(" SE295 does not exist in data and is mandatory"))
  if(has_name(data, "SE296") == FALSE | has_name(data, "INUSE_Q") == FALSE)
    stop(paste0(" INUSE_Q or SE296 do not exist in data and is mandatory"))
  if(is_logical(null_org) == FALSE)
    stop("null_org must be logical")


  # ORGANIC is still coded variable?
  if(FALSE %notin% (levels(factor(data$ORGANIC)) %in% 1:4)){
    message("decoding ORGANIC...")
    data <- GHGfromFADN::decode_organic(data)
    message("ORGANIC is now properly decoded")
  }

  if(FALSE %in% (levels(factor(data$ORGANIC)) %in% c("conventional", "mix", "organic", "converting")))
    stop("There is an issue with ORGANIC. Try again using the coded variable as provided by the FADN.")

  # 1- Clean data --------------------------------------------------------------

  # Build COUNTRY_YEAR if does not exist in data
  data <- data %>%
    mutate(COUNTRY_YEAR = paste(COUNTRY, YEAR, sep = "_"))

  # Get INUSE_Q (N in tons) from standard result SE296
  if(has_name(data, "SE296") == TRUE){
    data <- data %>%
      # SE296 is expressed in quintals whereas INUSE_Q is in tons
      mutate(INUSE_Q = SE296 / 10)
  }

  # 2- Predict INUSE_Q ----------------------------------------------------------

  if(null_org == TRUE){
    message("Predicting... INUSE_Q_pred = 0 for organic and converting farms (null_org = TRUE)")

    data_predict <-
      data %>%
      # fertiliser price index (base 100 in 2018)
      left_join(GHGfromFADN:::price_ferti, by = c("YEAR" = "YEAR")) %>%
      # prediction
      mutate(
        INUSE_Q_pred =
          case_when(
            # Only keep INUSE_Q value after 2017 (before they are unit issues, data unreliable)
            # Prediction for conventional and mix farms
            # equation: linear regression based on 2018 data
            YEAR < 2017 & ORGANIC %in% c("conventional", "mix") ~ 0.00083 * (REAL_FERTIN / 100) ^ -1 * SE295,
            YEAR > 2016 & ORGANIC %in% c("conventional", "mix") ~ INUSE_Q,
            # default: organic and converting, INUSE = 0
            ORGANIC %in% c("organic", "converting") ~ 0
          )
      ) %>%
      # remove the columns useful for the intermediate calculations
      select(-names(GHGfromFADN:::price_ferti)[names(GHGfromFADN:::price_ferti) != "YEAR"]) %>%
      # INUSE_Q in kg
      mutate(INUSE_Q_pred_kg = INUSE_Q_pred * 1000)
  }

  # 2-b Prediction even for organic and converting farms -----------------------

  if(null_org == FALSE){
    message("Predicting... even for organic and converting farms (null_org = FALSE)")

    data_predict <-
      data %>%
      # fertiliser price index (base 100 in 2018)
      left_join(GHGfromFADN:::price_ferti, by = c("YEAR" = "YEAR")) %>%
      # prediction
      mutate(
        INUSE_Q_pred =
          case_when(
            # Only keep INUSE_Q value after 2017 (before they are unit issues, data unreliable)
            # Prediction for all farms
            # equation: linear regression based on 2018 data
            YEAR < 2017 ~ 0.00083 * (REAL_FERTIN / 100) ^ -1 * SE295,
            YEAR > 2016 ~ INUSE_Q
          )
      ) %>%
      # remove the columns useful for the intermediate calculations
      select(-names(GHGfromFADN:::price_ferti)[names(GHGfromFADN:::price_ferti) != "YEAR"]) %>%
      # INUSE_Q in kg
      mutate(INUSE_Q_pred_kg = INUSE_Q_pred * 1000)
  }

  # 4- Out ---------------------------------------------------------------------

  return(data_predict)

}
