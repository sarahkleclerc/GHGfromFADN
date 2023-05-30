#' Estimate GHG emissions from crop residues
#'
#' @description We use IPCC 2006 Tier 1 estimate (equation 11.6) and emission factors.
#'
#' @usage ghg_cresidues(data, crop)
#'
#' @param data A dataframe.
#'
#' @return A dataframe with
#' \describe{
#'    \item{ghg_cresidues}{GHG emissions from crop residues, expressed in kg CO2e}
#' }
#'
#' @import dplyr
#'
#' @export

ghg_cresidues <- function(data, crop){

  if(crop %notin% c("CWHTC", "CBRL", "CMZ"))
    stop("crop must be one of the following codes: CWHTC, CBRL, CMZ")

  crop_text <- case_when(crop == "CWHTC" ~ "wheat",
                         crop == "CBRL" ~ "barley",
                         crop == "CMZ" ~ "maize")

  # GHG - Parameters --------------------------------------------------------

  # EF for nitrogen inputs to soil
  ef_1 <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "ef_1"]

  # ef_1 for flooded rice
  ef_1_fr <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "ef_1_fr"]

  # EF for leached nitrogen
  ef_5 <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "ef_5"]

  # Frac of N inputs leached as N
  frac_leach <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "frac_leach"]

  ## Reference values given in table 11.2 IPCC 2006
  dry <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == paste0("dry_", crop_text)]
  # slope parameter
  slope <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == paste0("ag_dry_slope_", crop_text)]
  # intercept parameter
  inter <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == paste0("ag_dry_inter_", crop_text)]
  # N content of above-ground crop residues
  n_ag <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == paste0("n_ag_", crop_text)]
  # Ratio of below-ground residues over above ground biomass
  r_bg_bio <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == paste0("r_bg_bio_", crop_text)]
  # N content of below-ground crop residues
  n_bg <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == paste0("n_bg_", crop_text)]

  # Frequency of re-seedeing
  frac_renew_annual <- 1
  frac_renew_pasture <- 0.25
  frac_renew <- frac_renew_annual

  # Frac of above-ground crop residues
  # We use value for france from Agreste for now
  frac_remove <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "frac_remove_agreste"]
  # For frac_remove = 0 (IPCC suggests 0 if no country specific data is available):
  # frac_remove <- param_n2o$value[param_n2o$code == "frac_remove"]

  # Conversion --------------------------------------------------------------

  # conversion n2o-N to N2O based on molar mass
  n2oN_to_n2o <- 44/28

  # conversion n2o to co2e
  # emission of 1 kg of nitrous oxide (N2O) equals 298 kg of CO2 equivalents
  n2o_to_co2 <- 298

  # Calculation -------------------------------------------------------------
  # IPCC equation 11.6

  data <- data %>%
    mutate(
      # area harvested of crop
      area = get(paste0(crop, "_TA"),.),
      # Dry weight correction (kg dm ha-1)
      kg_dm_ha = get(paste0(crop, "_YHA_kg"),.) * dry,
      # Dry weight correction (mg dm ha-1)
      mg_dm_ha = kg_dm_ha / 1000,
      # Above-ground residue dry matter (kg dm ha-1)
      ag_dm = (mg_dm_ha * slope + inter) * 1000,
      # N content of crop residues
      # f_cr = ag_dm * frac_renew * ((1-frac_remove) * n_ag + r_bg_bio * n_bg),
      f_cr = area * frac_renew * (ag_dm * n_ag * (1-frac_remove) + (ag_dm+kg_dm_ha) * r_bg_bio * n_bg),
      # GHG emissions from crop residues
      ghg_cresidues = f_cr * (ef_1 + ef_5 * frac_leach) * n2oN_to_n2o * n2o_to_co2
    )  %>%
    # remove intermediary variables
    select(-c("area", "kg_dm_ha", "mg_dm_ha", "ag_dm", "f_cr"))

  message("ghg_cresidues is expressed in kg CO2eq")

  # Return ------------------------------------------------------------------
  return(data)

}
