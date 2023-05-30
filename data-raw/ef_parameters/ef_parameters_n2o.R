### Emission factors and parameters for N2O emission calculations

# Read csv of the emission factors and parameters ----------------------------

param_n2o <- readr::read_csv2("data-raw/ef_parameters/ef_parameters_n2o.csv")

head(param_n2o)

# Add data to the package -------------------------------------------------
## Do this in the data-raw/internal_data.R script
