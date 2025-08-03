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
    "no_ncm_esp" = "ncm_description_es",
    "co_isic_classe" = "isic_class_code",
    "no_isic_classe" = "isic_class_desc_pt",
    "no_isic_classe_ing" = "isic_class_desc",
    "no_isic_classe_esp" = "isic_class_desc_es",
    "co_isic_grupo" = "isic_group_code",
    "no_isic_grupo" = "isic_group_desc_pt",
    "no_isic_grupo_ing" = "isic_group_desc",
    "no_isic_grupo_esp" = "isic_group_desc_es",
    "co_isic_divisao" = "isic_division_code",
    "no_isic_divisao" = "isic_division_desc_pt",
    "no_isic_divisao_ing" = "isic_division_desc",
    "no_isic_divisao_esp" = "isic_division_desc_es",
    "co_isic_secao" = "isic_section_code",
    "no_isic_secao" = "isic_section_desc_pt",
    "no_isic_secao_ing" = "isic_section_desc",
    "no_isic_secao_esp" = "isic_section_desc_es",
    "co_cgce_n3" = "bec_n3_code",
    "no_cgce_n3" = "bec_n3_desc_pt",
    "no_cgce_n3_ing" = "bec_n3_desc",
    "no_cgce_n3_esp" = "bec_n3_desc_es",
    "co_cgce_n2" = "bec_n2_code",
    "no_cgce_n2" = "bec_n2_desc_pt",
    "no_cgce_n2_ing" = "bec_n2_desc",
    "no_cgce_n2_esp" = "bec_n2_desc_es",
    "co_cgce_n1" = "bec_n1_code",
    "no_cgce_n1" = "bec_n1_desc_pt",
    "no_cgce_n1_ing" = "bec_n1_desc",
    "no_cgce_n1_esp" = "bec_n1_desc_es",
    "co_unid" = "unit_code"
    )

  rename_map <- name_map[names(name_map) %in% names(df)]
  for (old_name in names(rename_map)) {
    names(df)[names(df) == old_name] <- rename_map[[old_name]]
  }

  return(df)
}

#' Process a lookup/mapping table by name
#'
#' Helper function to get correlation tables from the Comex Stat portal
#'
#' @param name A character string indicating the internal name of the correlation table to process.
#'
#' @return A processed correlation table as a tibble or data frame.
#'
#' @noRd
process_table <- function(name) {
  link_table <- find_table_link(name)
  download_path <- download_correlation_table(link_table)
  read_correlation_table(download_path) |>
    rename_columns_if_present()
}
