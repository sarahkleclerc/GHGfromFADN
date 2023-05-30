# Fuel price from the weekly oil bulletin
# File downloaded on nov 4th 2022 (11/04/2022)

# 2005 onward
# WOB without tax


# libraries -----------------------------------------------------------------
library(tidyverse)
library(readxl)
library(farmsty)

# 2005 - 2022 -------------------------------------------------------------
# Automotive gas oil (EUR/L)
ob_wot_road = read_excel("data-raw/ref_fuel/Oil_Bulletin_Prices_History.xlsx",
                         sheet = "wotax_ctr_road",
                         range = "A64:S92")

ob_wot_road[ob_wot_road == 0] <- NA

ob_wot_road = ob_wot_road %>%
  pivot_longer(cols = names(.)[names(.) != "COUNTRY"],
               names_to = "YEAR",
               values_to = "PFUEL_ROAD")

# Heating gas oil (EUR/L)
ob_wot_heat = read_excel("data-raw/ref_fuel/Oil_Bulletin_Prices_History.xlsx",
                         sheet = "wotax_ctr_heat",
                         range = "A64:S92")

ob_wot_heat[ob_wot_heat == 0] <- NA

ob_wot_heat = ob_wot_heat %>%
  pivot_longer(cols = names(.)[names(.) != "COUNTRY"],
               names_to = "YEAR",
               values_to = "PFUEL_HEAT")

# Join

ref_fuel_wob = left_join(ob_wot_road, ob_wot_heat, by = c("COUNTRY", "YEAR")) %>%
  rename(country_eu = COUNTRY) %>%
  mutate(country_eu = if_else(country_eu == "GR", "EL", country_eu)) %>%
  left_join(farmsty::ref_country[,c("country_eu","country_fadn")], by = "country_eu") %>%
  rename(COUNTRY = country_fadn) %>%
  select(COUNTRY, country_eu, YEAR, PFUEL_ROAD, PFUEL_HEAT)

rm(ob_wot_road, ob_wot_heat)


# 2004 --------------------------------------------------------------------
# we have data for each country in a separate file

# list file paths
files <- list.files("data-raw/ref_fuel/oil_bulletin_country_and_years_before2005", pattern="*.xls", full.names=TRUE)
# read all files into a list
ldf <- lapply(files, read_excel)
# select usefull columns
ldf <- lapply(ldf, function(x) dplyr::select(x, all_of(c("Country_ID", "price_date", "Euro_Price", "DIESEL HT", "HGASOIL HT"))))
# bind into a single table
wob_old <- do.call("rbind", ldf)

# clean country code
wob_old$Country_ID[wob_old$Country_ID == "GR"] <- "EL"
wob_old$Country_ID[wob_old$Country_ID == "GB"] <- "UK"

# final calculations
wob_old <- wob_old %>%
  # keep only 2004
  filter(grepl("2004", price_date)) %>%
  mutate(YEAR = "2004") %>%
  # add country code
  rename(country_eu = Country_ID) %>%
  left_join(farmsty::ref_country[,c("country_eu","country_fadn")], by = "country_eu") %>%
  rename(COUNTRY = country_fadn) %>%
  # compute mean price for each country (NB: we only kep year 2004)
  group_by(COUNTRY) %>%
  mutate(PFUEL_HEAT = mean(`HGASOIL HT`, na.rm = T),
         PFUEL_ROAD = mean(`DIESEL HT`, na.rm = T)) %>%
  # conversion to EUR/L
  mutate(PFUEL_HEAT = PFUEL_HEAT/1000,
         PFUEL_ROAD = PFUEL_ROAD/1000) %>%
  ungroup() %>%
  # order cols and clean table
  select(COUNTRY, country_eu, YEAR, PFUEL_ROAD, PFUEL_HEAT) %>%
  # remove rows that appear more than once
  distinct()

rm(ldf, files)

# join to ref_fuel_wob
ref_fuel_wob = bind_rows(ref_fuel_wob, wob_old) %>%
  arrange(COUNTRY, YEAR)

rm(wob_old)
