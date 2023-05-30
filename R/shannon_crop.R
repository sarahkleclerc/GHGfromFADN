#' Shannon crop diversity index
#'
#' @description
#' Calculation of the crop Shannon Diversity Index - SDI.
#' A higher crop diversity index in absolute value indicates a more adaptative farm -> See Slijper et al 2022.
#' It should be noted that in this version of the crop diversity index, permanent crops are included.
#' crops are: cereals, other fieldcrops, vegetables & flowers, vineyards, permanent crops, other permanent crops, forages and woodlands.
#'
#' @usage shannon_crop(data)
#'
#' @param data A dataframe. Variables "SE035" "SE041" "SE046" "SE050" "SE054" "SE065" "SE071" "SE075" and "SE025" must be present.
#'
#' @return A dataframe with
#' \describe{
#'    \item{shannon_cdi}{Shannon Crop Diversity Index for a given farm and year}
#' }
#'
#' @import dplyr
#'
#' @export

shannon_crop <- function(data){

# Params ------------------------------------------------------------------

  # Crop surface variables
  # crops_i <-
  #   GHGfromFADN::dicovars %>%
  #   filter(group == "STANDARD RESULTS"
  #          & grepl("ha", comment)
  #          & ! grepl("/", comment)
  #          & ! grepl("ator", description)
  #          & ! grepl("use", description)) %>%
  #   filter(grepl("cereal|field|vegetables|flowers|vineyards|permanent|forage|wood", description,ignore.case=TRUE)) %>%
  #   pull(var)
  #
  # uaa <- GHGfromFADN::dicovars$var[grepl("total utilised agri", GHGfromFADN::dicovars$description, ignore.case = TRUE)]

  crops_i <- c("SE035", "SE041", "SE046", "SE050", "SE054", "SE065", "SE071")
  uaa <- "SE025"

# Tests -------------------------------------------------------------------

  # test that variables are in data
  lapply(append(crops_i, uaa), function(x){
    if(!x %in% names(data))
      stop(paste0(x, " is missing in data. \n",
                  "Mandatory variables: SE035, SE041, SE046, SE050, SE054, SE065, SE071, SE025"))
  })

# Data --------------------------------------------------------------------

  data <- data %>%
    mutate_at(crops_i, list(shareln = function(x){(x/get(uaa, .)) * log(x/get(uaa, .))})) %>%
    mutate(shannon_cdi = -rowSums(select(.,all_of(paste0(crops_i, "_shareln"))), na.rm = TRUE)) %>%
    select(-ends_with("_shareln"))

# Return ------------------------------------------------------------------

  return(data)

}
