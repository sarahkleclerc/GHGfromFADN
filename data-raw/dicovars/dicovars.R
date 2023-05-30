# Variables dictionary

library(dplyr)

dicovars <- readxl::read_excel("data-raw/dicovars/EEORG_rica datawarehouse variables to select_for_ext_use.xlsx",
                               sheet = "Selection of variables", range = "B1:G4872") %>%
  rename("var_pre2014" = "pre 2014 name",
         "var" = "COMMON name",
         "var_from2014" = "name from 2014",
         "description" = "DESCRIPTION",
         "comment" =  "Comment",
         "group" = "Group")

# Use data as external data -----------------------------------------------

# usethis::use_data(dicovars, overwrite = TRUE)
