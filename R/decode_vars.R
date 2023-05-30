#' Decode ORGANIC
#'
#' @description decode the ORGANIC variable
#'
#' @usage decode_organic(data)
#'
#' @param data A dataframe with the following variable: ORGANIC
#'
#' @return data with ORGANIC_c the coded variable and ORGANIC the decoded varaible.
#'
#' @import rlang
#' @import dplyr
#'
#' @export

decode_organic <- function(data){
  if(has_name(data, "ORGANIC") == FALSE)
    stop(paste0(" ORGANIC does not exist in ", data, " (data) and is mandatory"))

  data %>%
    # decode ORGANIC
    mutate(ORGANIC_c = ORGANIC,
           ORGANIC = case_when(ORGANIC_c == 1 ~ "conventional",
                               ORGANIC_c == 2 ~ "organic",
                               ORGANIC_c == 3 ~ "mix",
                               ORGANIC_c == 4 ~ "converting"
           ))
}


#' Decode TF14
#'
#' @description decode the TF14 variable
#'
#' @usage decode_tf14(data)
#'
#' @param data A dataframe with the following variable: TF14
#'
#' @return data with TF14_c the coded variable and TF14 the decoded varaible.
#'
#' @import rlang
#' @import dplyr
#'
#' @export

decode_tf14 <- function(data){
  if(has_name(data, "TF14") == FALSE)
    stop(paste0(" TF14 does not exist in ", data, " (data) and is mandatory"))

  data %>%
    # decode TF14
    mutate(TF14_c = TF14,
           TF14 = recode(TF14, "15" = "COP", "16" = "other_fieldcrops", "20" = "horticulture",
                         "35" = "wine", "36" = "orchards_fruits", "37" = "olives",
                         "38" = "permanent_crops", "45" = "milk", "48" = "sheep_goats",
                         "49" = "cattle", "50" = "granivores", "60" = "mixed_crops",
                         "70" = "mixed_livestock", "80" = "mixed_crops_livestock"))
}

#' Decode TF8
#'
#' @description decode the TF8 variable
#'
#' @usage decode_TF8(data)
#'
#' @param data A dataframe with the following variable: TF8
#'
#' @return data with TF8_c the coded variable and TF8 the decoded varaible.
#'
#' @import rlang
#' @import dplyr
#'
#' @export

decode_TF8 <- function(data){
  if(has_name(data, "TF8") == FALSE)
    stop(paste0(" TF8 does not exist in ", data, " (data) and is mandatory"))

  data %>%
    # decode TF8
    mutate(TF8_c = TF8,
           TF8 = recode(TF8, "1"="fieldcrops", "2"="horticulture", "3"="wine",
                        "4"="oth_perm_crops", "5"="milk", "6"="oth_grazing_livestock",
                        "7"="granivores", "8"="mixed"))
}

#' Decode SIZ6
#'
#' @description decode the SIZ6 variable, economic size classes with ES6 EU classification
#'
#' @usage decode_SIZ6(data)
#'
#' @param data A dataframe with the following variable: SIZ6
#'
#' @return data with SIZ6_c the coded variable and SIZ6 the decoded varaible.
#'
#' @import rlang
#' @import dplyr
#'
#' @export

decode_SIZ6 <- function(data){
  if(has_name(data, "SIZ6") == FALSE)
    stop(paste0(" SIZ6 does not exist in ", data, " (data) and is mandatory"))

  data %>%
    # decode SIZ6
    mutate(SIZ6_c = SIZ6,
           SIZ6 = recode(SIZ6, "1"="2 000 -< 8 000 EUR",
                         "2"="8 000 -< 25 000 EUR",
                         "3"="25 000 -< 50 000 EUR",
                         "4"="50 000 -< 100 000 EUR",
                         "5"="100 000 -< 500 000 EUR",
                         "6"=">= 500 000 EUR"))
}
