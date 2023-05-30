#' Value to quantity: Electricity IELE_Q
#'
#' @description Deduction of the quantity in MWH of electricity inputs
#' from the IELE_V value. We use Eurostat electricity price by country and year, excluding all taxesand levies.
#'
#' @usage vtoq_elec(data, method = "hh")
#'
#' @param data a dataframe, FADN data. Variables COUNTRY, YEAR and IELE_V must be present.
#' @param method a string. Default is "hh" when we take electricity price for households, Eurostat.
#' Otherwise can be "non_hh" for non-household consumers electricity price.
#'
#' @return data with variable IFULS_Q: Motor fuels and lubricants quantity
#'
#' @import dplyr
#'
#' @export

vtoq_elec <- function(data, method = "hh"){

  # Tests -------------------------------------------------------------------
  if(!exists("COUNTRY", data))
    stop("COUNTRY variable is required in data")
  if(!exists("YEAR", data))
    stop("YEAR variable is required in data")
  if(!exists("IELE_V", data))
    stop("IELE_V variable is required in data")

  if(method %notin% c("hh", "non_hh"))
    stop("method should take on of the following values:
         \n - 'hh': use household electricity price
         \n - 'non_hh': use non-household electricity price")


  # Electricity price -------------------------------------------------------
  if(method == "hh"){
    pelec <- GHGfromFADN:::pelec_hh
    message("Computing IELE_Q using household electricity price")
  }

  if(method == "non_hh"){
    pelec <- GHGfromFADN:::pelec_nothh
    message("Computing IELE_Q using non-household electricity price")
  }

  pelec <- pelec %>%
    # Keep years and countries we need
    filter(year %in% 2004:2019) %>%
    filter(country_fadn %in% GHGfromFADN::ref_country$country_fadn) %>%
    # Excluding taxes and levies
    filter(tax == "X_TAX") %>%
    # Select variables we need
    select(country_fadn, year, price_mean) %>%
    # One row per year x country
    distinct() %>%
    # rename price variable
    rename(price_elec = price_mean)

  # Electricity quantity ----------------------------------------------------

  data <- data %>%
    left_join(pelec, by = c("COUNTRY" = "country_fadn", "YEAR" = "year")) %>%
    mutate(IELE_KWH = IELE_V / price_elec,
           IELE_Q = IELE_KWH / 1000)

  # Return ------------------------------------------------------------------

  return(data)

}
