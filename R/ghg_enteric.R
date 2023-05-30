#' Estimate enteric fermentation GHG emissions
#'
#' @description CH4 emissions from enteric fermentation. Equation 10.19 from IPCC 2006.
#'
#' @usage ghg_enteric(data)
#'
#' @param data A dataframe.
#'
#' @return A dataframe with 3 columns:
#' \describe{
#'    \item{Country}{FADN country code}
#'    \item{Year}{Observation year}
#'    \item{GHG_enteric}{GHG emissions from enteric fermentation expressed in tCO2e}
#' }
#'
#' @import rlang
#' @import dplyr
#'
#' @export

ghg_enteric <- function(data){

  # ch4_enteric = ef_enteric *

  # Emission factor from IPCC guidelines.
  # We could also use country specific factors (national inventory reports)
}
