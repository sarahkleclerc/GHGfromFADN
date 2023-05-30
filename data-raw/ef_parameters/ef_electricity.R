### Electricity consumption GHG emission factors
# Source: JRC report
# Covenant of mayors for climate and energy: default emission factors for local emission inventories - Version 2017. Koffi et al.

# All EF are expressed in tCO2e per MWh

# Read csv of the emission factors (2008-2013) ----------------------------

ef_elec <- readr::read_csv2("data-raw/ef_parameters/ef_electricity.csv") %>%
  select(country_fadn, ef_elec) %>%
  rename(ef_elec_mwh = ef_elec) #%>% # tCO2e per MWh
  # Conversion MWH to KWH
  # 1MWH = 1000KWH -> ef_elec_kwh = ef_elec_mwh * 1000
  # mutate(ef_elec_kwh = ef_elec_mwh * 1000)

head(ef_elec)

# Add data to the package -------------------------------------------------
## Do this in the data-raw/internal_data.R script
