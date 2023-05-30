# Source R scripts
source("data-raw/ref_country/ref_country.R")
source("data-raw/electricity_price/electricity_price.R")
source("data-raw/ef_parameters/ef_electricity.R")
source("data-raw/ef_parameters/ef_parameters_n2o.R")
source("data-raw/ref_crops/ref_crops.R")
source("data-raw/price_ferti/price_ferti.R")
source("data-raw/ref_fuel/ref_fuel.R")
source("data-raw/ref_fuel/ref_fuel_wob.R")

# Add it all to internal data (R/sysdata.rda)
usethis::use_data(
  ref_country,
  # Electricity price
  pelec_hh, pelec_nothh,
  # Emission factors and parameters
  ef_elec, param_n2o,
  # Reference tables
  ref_crops,
  # Fertiliser price index
  price_ferti,
  # Fuel consumption and price
  ref_fuel, ref_fuel_wob,
  # Setup
  internal = TRUE, overwrite = TRUE
  )

rm(list = ls())
