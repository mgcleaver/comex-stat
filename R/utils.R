#' Comex Stat base URL
#' @keywords internal
cs_base_url <- "https://www.gov.br/mdic/pt-br/assuntos/comercio-exterior/estatisticas/base-de-dados-bruta"

#' Find URL of a correlation table on the Comex Stat website
#'
#' Searches the correlation tables page and returns the download link of a CSV file
#' that matches a given name.
#'
#' @param name Character. The name of the table (without the `.csv` extension) to find.
#' Some options are "PAIS" for countries and "UF" for states.
#'
#' @return A character vector with the download URL(s) matching the table name.
#'
#' @details The function parses the HTML content of the COMEX correlation tables page
#' and searches for `<a>` tags whose `href` attributes match the provided table name.
#'
#' @examples
#' \dontrun{
#'   find_table_link("PAIS")
#' }
#'
#' @keywords internal
#' @noRd
find_table_link <- function(name) {

  if (length(name) != 1 || !is.character(name)) {
    stop("`name` must be a single character string (e.g., 'PAIS').")
  }

  page <- rvest::read_html(cs_base_url)

  page |>
    rvest::html_elements("table tr td a") |>
    rvest::html_attr("href") |>
    stringr::str_subset(glue::glue("/{name}.csv"))
}

#' Download a Comex Stat correlation table
#'
#' Downloads a correlation table from a given URL and saves it to a temporary file.
#'
#' @param url Character. The full URL of the `.csv` file to download.
#'
#' @return A character string: the path to the downloaded file.
#'
#' @details Uses `httr::GET()` with a progress bar and temporary file destination.
#' The file is saved in a temporary directory using `withr::local_tempdir()`.
#'
#' @examples
#' \dontrun{
#'   url <- find_table_link("PAIS")
#'   path <- download_correlation_table(url)
#' }
#'
#' @keywords internal
#' @noRd
download_correlation_table <- function(url) {
  dest_dir <- tempfile(fileext = ".csv")

  resp <- httr::GET(url, httr::write_disk(dest_dir, overwrite = TRUE), httr::progress())

  if (httr::http_error(resp)) {
    stop("Download error: ", httr::http_status(resp)$message)
  }

  if (!file.exists(dest_dir) || file.info(dest_dir)$size == 0) {
    stop("Download failed: file doesn't exist or empty.")
  }
  message(glue::glue("✔ Download complete\n"))
  return(dest_dir)
}

#' Read a correlation table from a CSV file
#'
#' Reads a correlation table from a CSV file using `read.csv2` and returns
#' a clean names `tibble`.
#'
#' @param path Character. Full path to the `.csv` file to read.
#'
#' @return A `tibble` containing the cleaned correlation table.
#'
#' @details Uses Latin-1 encoding. Column names are cleaned using `janitor::clean_names()`.
#'
#' @examples
#' \dontrun{
#'   url <- find_table_link("PAIS")
#'   path <- download_correlation_table(url)
#'   df <- read_correlation_table(path)
#' }
#'
#' @keywords internal
#' @noRd
read_correlation_table <- function(path) {
  read.csv2(
    path,
    fileEncoding = "Latin1",
    stringsAsFactors = FALSE
  ) |>
    janitor::clean_names() |>
    tibble::as_tibble()
}

#' Rename selected columns if present in a data frame
#'
#' This internal helper function checks whether specific column names are present in the input tibble
#' and renames them to standardized English equivalents if found. It is meant to
#' be used after calling read_correlation_table.
#'
#' @param df A `data.frame` or `tibble`. The input data containing original column names.
#'
#' @return A `data.frame` or `tibble` with selected columns renamed, if present. Columns not listed in the
#' renaming map remain unchanged.
rename_columns_if_present <- function(df) {

  name_map <- c(
    "co_pais" = "country_code",
    "co_pais_ison3" = "country_code_ison3",
    "co_pais_isoa3" = "country_code_isoa3",
    "no_pais" = "country_name_pt",
    "no_pais_ing" = "country_name",
    "no_pais_esp" = "country_name_es",
    "co_uf" = "state_code",
    "sg_uf" = "state",
    "no_uf" = "state_name",
    "co_ncm" = "ncm",
    "no_ncm_ing" = "ncm_description",
    "no_ncm_por" = "ncm_description_pt",
    "no_ncm_esp" = "ncm_description_es"
    )

  cols_to_rename <- intersect(names(name_map), names(df))

  if (length(cols_to_rename) == 0) {
    return(df)  # No matching columns, return unchanged
  }

  names(df)[names(df) %in% cols_to_rename] <- name_map[cols_to_rename]

  return(df)
}
