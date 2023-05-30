################################################################################
############             Fertiliser price index                    ############
################################################################################


# Information about the data ----------------------------------------------

## Data was downloaded from world bank website on 09/15/2022.
# Time series of fertiliser price from the World Bank Commodity Price Data (The Pink Sheet).
# We use real price index base 100 in 2010 and want base 100 in 2018
# NB: time series in France have the same trends

# Import data -------------------------------------------------------------
# Install and load a few libraries
if (!require("tidyverse")) install.packages("tidyverse") # Data import and manipulation
if (!require("readxl")) install.packages("readxl") # Data import and manipulation
library(tidyverse)

ferti_price_ps <-
  readxl::read_excel("data-raw/price_ferti/World Bank Commodity Price Data (The Pink Sheet) - Annual.xlsx",
                     sheet = "fertilizer-index") %>%
  filter(YEAR %in% 2004:2019)

# Clean -------------------------------------------------------------------
# transformation: base 100 in 2018 instead of 2010
ref_2018 <- ferti_price_ps$REAL_FERTI_INDEX[ferti_price_ps$YEAR == 2018]

price_ferti <- ferti_price_ps %>%
  mutate(REAL_FERTIN = REAL_FERTI_INDEX / ref_2018 * 100) %>%
  select(YEAR, REAL_FERTIN)

# ## Plot to check:
# ggplot(price_ferti, aes(y=REAL_FERTIN, x=YEAR)) +
#   geom_hline(yintercept = 100, colour = "grey") +
#   geom_line() +
#   geom_point() +
#   theme_classic()

rm(ref_2018, ferti_price_ps)

# Add data to the package -------------------------------------------------
# usethis::use_data(price_ferti, internal = TRUE, overwrite = TRUE)
