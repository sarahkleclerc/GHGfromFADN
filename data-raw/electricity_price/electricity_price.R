################################################################################
############                  Electricity price                     ############
################################################################################


# Information about the data ----------------------------------------------

## Data was downloaded from eurostat website on 02/17/2022.
# Eurostat : Energy statistics - prices of electricity

## Until 2007:
# - Electricity prices for domestic consumers - bi-annual data (until 2007) (nrg_pc_204_h)
# - Electricity prices for industrial consumers - bi-annual data (until 2007) (nrg_pc_205_h)

## From 2007 - 2021:
# - Electricity prices for household consumers - bi-annual data (from 2007 onwards) (nrg_pc_204)
# - Electricity prices for non-household consumers - bi-annual data (from 2007 onwards) (nrg_pc_205)

## /!\ Taxes
# X_TAX: Excluding taxes and levies
# X_VAT: Excluding VAT and other recoverable taxes and levies
# I_TAX: All taxes and levies included


# Import data -------------------------------------------------------------
# Install and load a few libraries
if (!require("tidyverse")) install.packages("tidyverse") # Data import and manipulation
library(tidyverse)
if (!require("stringr")) install.packages("stringr") # Strings manipulation

## household consumers
nrg_pc_204_h <- readr::read_tsv("data-raw/electricity_price/nrg_pc_204_h.tsv.gz")

nrg_pc_204 <- readr::read_tsv("data-raw/electricity_price/nrg_pc_204.tsv.gz")

## non-household consumers
nrg_pc_205_h <- readr::read_tsv("data-raw/electricity_price/nrg_pc_205_h.tsv.gz")

nrg_pc_205 <- readr::read_tsv("data-raw/electricity_price/nrg_pc_205.tsv.gz")

# Clean -------------------------------------------------------------------
# data names
data_name <- c("nrg_pc_204_h", "nrg_pc_204", "nrg_pc_205_h", "nrg_pc_205")

# Split first column of all tables
lapply(data_name, function(x){
  table <- get(x, envir = .GlobalEnv)
  # Split first column
  split <- as.data.frame(str_split(pull(table, 1), ",", simplify = TRUE)) %>%
    rename("product" = V1, "consom" = V2, "unit" = V3, "tax" = V4, "currency" = V5, "geo" = V6)
  # render the result
  assign(x, cbind(split, table[, 2:ncol(table)]), envir = .GlobalEnv)
})

# Replace missing values by NA
nrg_pc_204_h[nrg_pc_204_h == ":"] <- NA
nrg_pc_204[nrg_pc_204 == ":"] <- NA
nrg_pc_205_h[nrg_pc_205_h == ":"] <- NA
nrg_pc_205[nrg_pc_205 == ":"] <- NA

# Year average price
# BY product, consom, unit, tax, currency, geo, year
lapply(data_name, function(x){
  table <- get(x, envir = .GlobalEnv)

  ### Step 1 : pivot table, create a columns "year" and "price"
  pivot <- pivot_longer(table, cols = names(table)[7:ncol(table)], names_to = "year", values_to = "price")

  ### Step 2 : extract year
  pivot$year <- str_extract(pivot$year, "[0-9]+")

  ### Step 3 : compute mean by year
  # BY product, consom, unit, tax, currency, geo, year
  pivot_mean <- pivot %>%
    mutate(year = as.numeric(year),
           price = as.numeric(price)) %>%
    group_by(product, consom, unit, tax, currency, geo, year) %>%
    mutate(price = mean(price, na.rm = TRUE)) %>%
    ungroup() %>%
    distinct()

  # render the modified table
  assign(x, pivot_mean, envir = .GlobalEnv)
})

# Add FADN country codes
lapply(data_name, function(x){
  table <- get(x, envir = .GlobalEnv)
  # Reference table for countries (exported data in the package)
  country_tab <- select(farmsty::ref_country, country_eu, country_fadn)

  table <- full_join(table, country_tab, by = c("geo" = "country_eu")) %>%
    rename(country_eu = geo) %>%
    select(product, consom, unit, tax, currency, country_eu, country_fadn, year, price)

  # render the modified table
  assign(x, table, envir = .GlobalEnv)
})

# Average price per country, year and currency
lapply(data_name, function(x){
  table <- get(x, envir = .GlobalEnv)

  table <- table %>%
    group_by(year, country_eu, currency) %>%
    mutate(price_mean = mean(price, na.rm = TRUE)) %>%
    ungroup()

  # render the modified table
  assign(x, table, envir = .GlobalEnv)
})

# Combine -----------------------------------------------------------------

# 2007 is present in both datasets, we keep the value in nrg_pc_204 and nrg_pc_205 (the new table)
nrg_pc_204_h <- filter(nrg_pc_204_h, year != 2007)
nrg_pc_205_h <- filter(nrg_pc_205_h, year != 2007)

# price of electricity for households
pelec_hh <- bind_rows(nrg_pc_204_h, nrg_pc_204) %>%
  arrange(year) %>%
  filter(currency == "EUR") %>%
  filter(year > 1999)

# price of electricity for non households
pelec_nothh <- bind_rows(nrg_pc_205_h, nrg_pc_205) %>%
  arrange(year) %>%
  filter(currency == "EUR") %>%
  filter(year > 1999)

rm(nrg_pc_204, nrg_pc_205, nrg_pc_204_h, nrg_pc_205_h, data_name)

# Add data to the package -------------------------------------------------
# usethis::use_data(pelec_hh, pelec_nothh, internal = TRUE, overwrite = TRUE)
