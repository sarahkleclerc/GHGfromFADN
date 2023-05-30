## Reference country table code
# Data available to the user (external data)

library(tidyverse)

# Read file ---------------------------------------------------------------
country_tab <- load("data-raw/ref_country/ref_country.rda") #readr::read_rds
# %>%
#   rename(country_fadn = country_FADN)

# Some data wrangling -----------------------------------------------------
# country_eu <- tibble(country_name = c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany",
#                                       "Estonia", "Ireland", "Greece", "Spain", "France", "Croatia",
#                                       "Italy", "Cyprus", "Latvia", "Lithuania", "Luxembourg",
#                                       "Hungary", "Malta", "Netherlands", "Austria", "Poland",
#                                       "Portugal", "Romania", "Slovenia", "Slovakia", "Finland", "Sweden",
#                                       "United Kingdom", "Czech Republic"),
#                      country_eu = c("BE", "BG", "CZ", "DK", "DE", "EE", "IE", "EL", "ES", "FR", "HR", "IT", "CY",
#                                     "LV", "LT", "LU", "HU", "MT", "NL", "AT", "PL", "PT", "RO", "SI", "SK", "FI", "SE",
#                                     "UK", "CZ"))
#
# ref_country <- left_join(country_tab, country_eu)
#
# rm(country_tab, country_eu)

# Use data as external data -----------------------------------------------

# usethis::use_data(ref_country, overwrite = TRUE)
