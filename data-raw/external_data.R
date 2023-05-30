source("data-raw/ref_country/ref_country.R")
source("data-raw/dicovars/dicovars.R")
source("data-raw/ref_nuts/ref_nuts.R")

# Add it all to external data
usethis::use_data(
  # country
  ref_country,
  # variable dictionnary
  dicovars,
  # NUTS geometry
  ref_nuts,
  # Setup
  overwrite = TRUE
)

rm(list = ls())
