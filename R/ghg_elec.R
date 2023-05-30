#' Estimate GHG emissions from electricity consumption for a given crop
#'
#' @description Emissions from electricity inputs, in kg CO2eq
#'
#' @usage ghg_elec(data, crop, emission_factor = "EU")
#'
#' @param data A dataframe. Variables COUNTRY, YEAR, IELE_V must be present.
#' @param crop A string - crop code from FADN variables. Must be one of the following: CWHTC, CBRL, CMZ.
#' @param emission_factor A string. \code{"country"} when GHG emissions should be estimated using country
#' specific emission factors. \code{"EU"}, default, when GHG emissions should be estimated using a unique
#' emission factor for all EU countries.
#'
#' @return A dataframe with
#' \describe{
#'    \item{ghg_elec}{GHG emissions from electricity inputs expressed in kg CO2e}
#' }
#'
#' @import dplyr
#'
#' @export

ghg_elec <- function(data, crop, emission_factor = "EU"){


  # Tests -------------------------------------------------------------------

  if(emission_factor %notin% c("EU", "country"))
    stop("emission_factor should take a value in c('EU', 'country')")


  # Quantity of electricity IELE_Q ------------------------------------------

  data <- data %>%
    # value to quantity elec (in KWH)
    vtoq_elec()

  # Emission factor / EU ----------------------------------------------------
  if(emission_factor == "EU"){
    EF_elec <- GHGfromFADN:::ef_elec %>% # EF expressed in tCO2eq/MWH
      mutate(ef_elec_mwh = 1000 * ef_elec_mwh) %>%  # EF expressed in kgCO2eq/MWH
      filter(country_fadn == "EU") %>%
      pull(ef_elec_mwh)

    data <- data %>%
      # GHG kg CO2-eq with an economic allocation to the crop
      mutate(ghg_elec = IELE_Q * EF_elec * get(paste0(crop, "_TO_TOC"),.))

    message("ghg_elec: EU emission factor was used")
  }

  # Emission factor / country -----------------------------------------------

  if(emission_factor == "country"){
    EF_elec <- GHGfromFADN:::ef_elec %>% # EF expressed in tCO2eq/MWH
      mutate(ef_elec_mwh = 1000 * ef_elec_mwh) %>%  # EF expressed in kgCO2eq/MWH
      filter(country_fadn != "EU") %>%
      # we want EF expressed in tCO2eq/MWH
      select(country_fadn, ef_elec_mwh)

    data <- data %>%
      left_join(EF_elec, by = c("COUNTRY" = "country_fadn")) %>%
      # GHG kg CO2-eq with an economic allocation to the crop
      mutate(ghg_elec = IELE_Q * ef_elec_mwh * get(paste0(crop, "_TO_TOC"),.)) %>%
      select(-ef_elec_mwh)

    message("ghg_elec: country-specific emission factors were used")
    return(data)
  }

  # End of the function -------------------------------------------------------

  message("ghg_elec is expressed in kg CO2eq")

  return(data)
}
