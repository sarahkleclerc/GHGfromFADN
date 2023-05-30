### Reference table of crop variables
# Correspondance between crop types from FADN to crop categories from IPCC (2006) table 11.2

# Read csv of the emission factors and parameters ----------------------------

ref_crops <- readr::read_csv2("data-raw/ref_crops/ref_crops.csv")

# save(ref_crops, file = "data-raw/ref_crops/ref_crops.rda")

# Add data to the package -------------------------------------------------
## Do this in the data-raw/internal_data.R script


