#' Bind FADN data files together
#'
#' For EU FADN data.
#'
#' @param directory String. Path to files.
#' @param country String. FADN country code.
#' @param start_year Number. First year of the year interval to be combined.
#' @param end_year Number. First year of the year interval to be combined.
#' @param save_as String. \code{"csv"} to save as a csv file, \code{"R"} to save as Rdata file. If \code{NULL} (defaut) then returns the table.
#' @param save_dir String. Saving directory is different than directory.
#'
#' @import rlang
#' @export

bind_fadn <- function(
  directory,
  country,
  start_year,
  end_year,
  save_as = NULL,
  save_dir
){

  ## A few checks...
  if(is.character(directory) == FALSE)
    stop("directory should be a string")
  if(is.character(country) == FALSE)
    stop("country should be a string")
  if(country %notin% ref_country$country_fadn)
    stop("country should be one of the FADN country codes. See the list of countries in ref_country.")
  if(is.numeric(start_year) == FALSE)
    stop("start_year should be numeric")
  if(is.numeric(end_year) == FALSE)
    stop("end_year should be numeric")

  years <- start_year:end_year

  # List
  data_list <- lapply(years, function(x) read_FADN(directory, country, x))
  data_list <- data_list[lengths(data_list)>1]

  # To table
  data_tab <- Reduce(rbind, data_list)

  # Save .csv
  if(save_as == "csv"){
    write.csv(data_tab, paste0(if_else(is.null(save_dir) == TRUE, directory, save_dir), "bind_data/", country, ".csv"), row.names = FALSE)
  }
  # Save .Rdata
  if(save_as == "R"){
    saveRDS(data_tab, paste0(if_else(is.null(save_dir) == TRUE, directory, save_dir), "bind_data/", country, ".Rdata"))
  }
  # Return the table
  if(is.null(save_as)){
    return(data_tab)
  }
}
