#' Estimate GHG emissions from synthetic fertilisers inputs
#'
#' @description We use IPCC 2006 Tier 1 estimate and emission factor.
#' Direct emissions and emissions from leaching are included.
#' We chose an economic allocation of fertiliser inputs to each crop production.
#'
#' @usage ghg_fertilisers(data, crop)
#'
#' @param data A dataframe.
#' @param crop A string - crop code from FADN variables. Must be one of the following: CWHTC, CBRL, CMZ.
#'
#' @return A dataframe with
#' \describe{
#'    \item{ghg_ferti_use}{GHG emissions from synthetic fertiliser use, expressed in kg CO2e}
#'    \item{ghg_ferti_prod}{GHG emissions from synthetic fertiliser production, expressed in kg CO2e}
#' }
#'
#' @import dplyr
#'
#' @export

ghg_fertilisers <- function(data, crop){

  if(!crop %in% c("CWHTC", "CBRL", "CMZ"))
    stop("crop must be one of the following codes: CWHTC, CBRL, CMZ")

  # GHG - Parameters --------------------------------------------------------

  # EF for nitrogen inputs to soil
  ef_1 <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "ef_1"]

  # ef_1 for flooded rice
  ef_1_fr <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "ef_1_fr"]

  # EF for leached nitrogen
  ef_5 <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "ef_5"]

  # Frac of volatilised N for synthetic inputs
  frac_gasf <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "frac_gasf"]

  # Frac of N inputs leached as N
  frac_leach <- GHGfromFADN:::param_n2o$value[GHGfromFADN:::param_n2o$code == "frac_leach"]

  # EF of fertiliser production
  # Source: International fertiliser society, The carbon footprint of fertiliser production (Hoxha & Christensen, 2018)
  # I take the mean of all EF presented ; EU average ; unit : kgCO2e/kg nitrogen
  ef_ferti_prod <- 3.5
  # NB: it is possible that it is overvalued for urea fertilisers and undervalued for ammonium nitrate fertilisers
  # But overall it is consistent with the review of Walling & Vaneeckhaute (2020) considering the recent innovation in Europe to reduce carbone content of AN fertilisers.

   # Conversion --------------------------------------------------------------

  # conversion n2o-N to N2O based on molar mass
  n2oN_to_n2o <- 44/28

  # conversion n2o to co2e
  # emission of 1 kg of nitrous oxide (N2O) equals 298 kg of CO2 equivalents
  n2o_to_co2 <- 298


  # INUSE_Q_pred ------------------------------------------------------------

  if(!exists("INUSE_Q_pred", data)){
    data <- predict_inuse(data)
  }

  # Calculation -------------------------------------------------------------
  # $n2o_{synthetic\_nitrogen} = F_{SN} (EF_1 (1 + Frac_{GASF}) + EF_5 Frac_{LEACH})\frac{44}{28}$
  #
  #   Where
  # - $EF_1$ is the emission factor for nitrogen inputs to soil (IPCC, 2006)
  # - $EF_5$ is the emission factor for leached nitrogen (IPCC, 2006)
  # - $Frac_{GASF}$ is the fraction of volatilised nitrogen for synthetic inputs (IPCC, 2006)
  # - $Frac_{LEACH}$ is the fraction of nitrogen inputs leached as nitrate (IPCC, 2006)

  # *NB:*
  #
  # -   We never use the emission factor for flooded rice `ef_1_fr`. We have the quantity of mineral fertiliser input for the whole farm and not for each crop. Following the LCA methodology (ILCD Handbook, JRC 2010) [\@europeancommission.jointresearchcentre.instituteforenvironmentandsustainability2010] we estimate emissions at the sub-system level where possible and otherwise allocate system emissions. Alternatively we could have regressed the inputs by the area of each crop as in the 4 per 1000 study (INRAE).
  #
  # -   Allocation of emissions from synthetic fertilisers: We allocate emissions to the extent that the crop contributes to the overall crop output of the farm.

  data <- data %>%
    mutate(INUSE_Q_pred_kg = INUSE_Q_pred * 1000) %>%
    mutate(
      # GHG from fertiliser use
      ghg_ferti_use = (INUSE_Q_pred_kg * (ef_1 * (1 + frac_gasf) + ef_5 * frac_leach)) * get(paste0(crop, "_TO_TOC"), .) * n2oN_to_n2o * n2o_to_co2,
      # GHG from fertiliser production
      ghg_ferti_prod = INUSE_Q_pred_kg * get(paste0(crop, "_TO_TOC"), .) * ef_ferti_prod
    )

  message("ghg_ferti_use is expressed in kg CO2eq")
  message("ghg_ferti_prod is expressed in kg CO2eq")


  # Return ------------------------------------------------------------------
  return(data)

}
