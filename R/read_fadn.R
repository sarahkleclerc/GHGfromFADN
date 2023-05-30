#' Read data
#'
#' @description Read FADN data
#'
#' @usage read_fadn(directory, country, year, select_col)
#'
#' @param directory A string. Path to the data files.
#' @param country A string. FADN country code.
#' @param year A number. Year to read.
#' @param select_col A vector or string. Name of columns to select in data, avoids reading the whole - huge - table.
#'
#' @return A dataframe with country, year and columns selected.
#' @import rlang
#' @import dplyr
#' @export


read_fadn <- function(directory, country, year, select_col){

  ##### A few checks
  if(is.character(directory) == FALSE)
    stop("directory should be a string")
  if(is.character(country) == FALSE)
    stop("country should be a string")
  if(country %notin% GHGfromFADN::ref_country$country_fadn)
    stop("country should be one of the FADN country codes. See the list of countries in ref_country.")
  if(is.numeric(year) == FALSE)
    stop("year should be numeric")
  if(rlang::is_missing(select_col) == FALSE && is.vector(select_col) == FALSE)
    stop("if not missing, select_col should be a vector")

  #### Action!!

  if(file.exists(paste0(directory, country, as.character(year), ".csv")) == TRUE){
    tab <-
      read.csv(paste0(directory, country, as.character(year), ".csv")) %>%
      # Add country
      mutate(Country = country) %>%
      # Add the year in the table
      mutate(Year = as.numeric(year)) %>%
      # Arrange columns of the table ('Year' first)
      select(Year, everything())

    # Select only a few variables
    if(rlang::is_missing(select_col) == FALSE){
      tab <- tab %>%
        select(Year, Country, select_col)
    }

  } else {
    warning("The file does not exist. Check directory or country spelling.")
    tab <- dplyr::tibble(Year = as.character(year))
  }

  return(tab)
}
