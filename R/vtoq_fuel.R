#' Value to quantity: Motor fuels and lubricants IFULS
#'
#' @description Deduction of the quantity of fuel consumed for engines -in MJ-
#' from the IFULS_V value
#'
#' @usage vtoq_fuel_motors(data, method = "wob")
#'
#' @param data a dataframe, FADN data. Variables COUNTRY, YEAR and IFULS_V must be present.
#' @param method a string. Default is method="wob" to use prices of gasoline excluding taxes
#' as provided in the weekly oil bulletin - eurostat.
#' method="unfcc" to deduce a price from the total consumption of fuels in
#' sector by country and year as provided in the national inventory report - UNFCC.
#'
#' @return data with variable IFULS_Q: Motor fuels and lubricants quantity
#'
#' @import dplyr
#'
#' @export

vtoq_fuel_motors <- function(data, method = "wob"){

  # data <- sample_n(data_lift, 1000) %>%
  #   select(id, COUNTRY, YEAR, ORGANIC, IFULS_V)

  # Tests -------------------------------------------------------------------
  if(!exists("COUNTRY", data))
    stop("COUNTRY variable is required in data")
  if(!exists("YEAR", data))
    stop("YEAR variable is required in data")
  if(!exists("IFULS_V", data))
    stop("IFULS_V variable is required in data")
  if(method %notin% c("wob", "unfcc"))
    stop("method value must be 'wob' or 'unfcc'")

    ############### METHOD WOB  -------------------------------------------------
  # Weekly oil bulletin (Eurostat) method: we use the gasoline price excluding taxes

  if(method == "wob"){
    # reference data ----------------------------------------------------------
    ref_fuel_wob <- GHGfromFADN:::ref_fuel_wob %>%
      select(COUNTRY, YEAR, PFUEL_ROAD)

    # NB: PFUEL_ROAD is expressed in EUR/L

    # For each farm -----------------------------------------------------------
    class_year <- paste0("as.", class(get("YEAR", data)))

    data <- data %>%
      # YEAR as character to match the class of ref_fuel$year
      mutate(YEAR = as.character(YEAR)) %>%
      # Add gasoline price for automotive use, excluding taxes
      left_join(ref_fuel_wob, by = c("COUNTRY" = "COUNTRY", "YEAR" = "YEAR")) %>%
      # YEAR returns to its original class
      mutate(YEAR = eval(parse(text = paste0(class_year, "(as.character(YEAR))")))) %>%
      # calculation of consumption (quantity) per farm
      mutate(IFULS_Q = IFULS_V / PFUEL_ROAD) %>%
      # 1 litre of diesel = 37,9 MJ (Conversion for Diesel only) Ref: University of Strathclyde and HM Treasury
      mutate(IFULS_Q = IFULS_Q * 37.9)

    message("IFULS_Q: Quantity of fuels for motors, in MJ")

    return(data)
  }

  ############### METHOD UNFCC  -----------------------------------------------
  # We deduce a price from the total consumption of fuels in sector by country and year
  # as provided in the national inventory reports (UNFCC)

  if(method == "unfcc"){
    # reference data ----------------------------------------------------------
    ref_fuel <- GHGfromFADN:::ref_fuel %>%
      select(country_fadn, year, price_motors)

    # For each farm -----------------------------------------------------------
    class_year <- paste0("as.", class(get("YEAR", data)))

    data <- data %>%
      # YEAR as character to match the class of ref_fuel$year
      mutate(YEAR = as.character(YEAR)) %>%
      # Add total consumption and total value of fuel oil for agricultural use on engines
      left_join(ref_fuel, by = c("COUNTRY" = "country_fadn", "YEAR" = "year")) %>%
      # YEAR returns to its original class
      mutate(YEAR = eval(parse(text = paste0(class_year, "(as.character(YEAR))")))) %>%
      # calculation of consumption (quantity) per farm - in TJ -
      mutate(IFULS_Q = IFULS_V / price_motors) %>%
      # conversion TJ to MJ
      mutate(IFULS_Q = IFULS_Q * 1000000)

    message("IFULS_Q: Quantity of fuels for motors, in MJ")

    return(data)
  }

}

#' Value to quantity: Heating fuels IHFULS
#'
#' @description Deduction of the quantity of fuel consumed for heating -in MJ-
#' from the IHFULS_V value and the price of gasoline for heating from the weekly oil bulletin, eurostat.
#'
#' @usage vtoq_fuel_heating(data)
#'
#' @param data a dataframe, FADN data. Variable COUNTRY, YEAR and IHFULS_V must be present.
#'
#' @return data with variable IHFULS_Q: Heating fuels quantity
#'
#' @import dplyr
#'
#' @export

vtoq_fuel_heating <- function(data){

  # Tests -------------------------------------------------------------------
  if(!exists("COUNTRY", data))
    stop("COUNTRY variable is required in data")
  if(!exists("YEAR", data))
    stop("YEAR variable is required in data")
  if(!exists("IHFULS_V", data))
    stop("IHFULS_V variable is required in data")

  # reference data ----------------------------------------------------------
  ref_fuel_wob <- GHGfromFADN:::ref_fuel_wob %>%
    select(COUNTRY, YEAR, PFUEL_HEAT)

  # NB: PFUEL_HEAT is expressed in EUR/L

  # For each farm -----------------------------------------------------------
  # Weekly oil bulletin (Eurostat) method: we use the gasoline price excluding taxes

  class_year <- paste0("as.", class(get("YEAR", data)))

  data <- data %>%
    # YEAR as character to match the class of ref_fuel$year
    mutate(YEAR = as.character(YEAR)) %>%
    # Add gasoline price for automotive use, excluding taxes
    left_join(ref_fuel_wob, by = c("COUNTRY" = "COUNTRY", "YEAR" = "YEAR")) %>%
    # YEAR returns to its original class
    mutate(YEAR = eval(parse(text = paste0(class_year, "(as.character(YEAR))")))) %>%
    # calculation of consumption (quantity) per farm
    mutate(IHFULS_Q = IHFULS_V / PFUEL_HEAT) %>%
    # 1 litre of diesel = 37,9 MJ (Conversion for Diesel only) Ref: University of Strathclyde and HM Treasury
    mutate(IHFULS_Q = IHFULS_Q * 37.9)

  message("IHFULS_V: Quantity of fuels for heating, in MJ")

  return(data)

}
