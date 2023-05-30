#' Estimate GHG emissions from fuels consumption for a given crop
#'
#' @description Emissions from motors and heating, in kg CO2eq
#'
#' @usage ghg_fuels(data, crop, EF_motors = 0.082, EF_heat = 0.0751)
#'
#' @param data A dataframe. Variables COUNTRY, YEAR, IFULS_V and IHFULS_V must be present.
#' @param crop A string - crop code from FADN variables. Must be one of the following: CWHTC, CBRL, CMZ.
#' @param EF_motors A numeric value. Emission factor for diesel used in motors.
#' Default value is taken from IPCC 2006, vol 2 - table 3.3.1.
#' @param EF_heat A numeric value. Emission factor for diesel, stationary use in agriculture sector.
#' Default value is taken from IPCC 2006, vol 2 -table 2.5.
#'
#' @return A dataframe with
#' \describe{
#'    \item{ghg_fuels_motors}{GHG emissions from motor fuels and lubricants expressed in kg CO2e}
#'    \item{ghg_fuels_heat}{GHG emissions from fuels used for heating expressed in kg CO2e}
#' }
#'
#' @import dplyr
#'
#' @export

ghg_fuels <- function(data, crop, EF_motors = 0.082, EF_heat = 0.0751){

  # Motors fuels ------------------------------------------------------------

  # Parameters ---------------------

  # EF for Diesel Fuel - Other Diesel Non-Road Vehicles
  # Source: GHG Protocol - Emission Factors from Cross-Sector Tools (EPA : https://www.epa.gov/climateleadership/center-corporate-climate-leadership-ghg-emission-factors-hub)
  # 10,30173 kgCO2e / gallon (US)
  # i.e. 2.7 kgCO2e/litre
  # i.e. 0.0712kgCO2e/MJ
  # 1 litre of diesel = 37,9 MJ (Conversion for Diesel only) Ref: University of Strathclyde and HM Treasury
  # 1 gallon (US) = 3.7854 litres
  # EF_motors <- 0.0712 # kgCO2e/MJ

  # GHG calculation ----------------
  data <- data %>%
    # value to quantity motor fuels (in MJ)
    vtoq_fuel_motors() %>%
    # GHG kg CO2-eq/MJ with an economic allocation to the crop
    mutate(ghg_fuels_motors = IFULS_Q * EF_motors * get(paste0(crop, "_TO_TOC"),.))

  message("ghg_fuels_motors is expressed in kg CO2eq")

  # Heating fuels ------------------------------------------------------------

  # IPCC 2006 emission factor for stationary diesel use in agriculture (table 2.5)
  # EF_heat <- 0.0741 # kgCO2/MJ

  # GHG calculation ----------------
  data <- data %>%
    # value to quantity motor fuels (in MJ)
    vtoq_fuel_heating() %>%
    # GHG kg CO2-eq/MJ with an economic allocation to the crop
    mutate(ghg_fuels_heat = IFULS_Q * EF_heat * get(paste0(crop, "_TO_TOC"),.))

  message("ghg_fuels_heat is expressed in kg CO2eq")

  # End of the function -------------------------------------------------------

  return(data)
}
