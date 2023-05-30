# EU NUTS
# file downloaded on 11/21/2022
# https://ec.europa.eu/eurostat/fr/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts

library(sf)

# ref_nuts <- st_read("data-raw/ref_nuts/NUTS_RG_20M_2021_3035.shp",quiet = TRUE)
ref_nuts <- st_read("data-raw/ref_nuts/NUTS_RG_60M_2013_3035.shp",quiet = TRUE)

