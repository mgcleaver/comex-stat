#' Create Arrow Schema for Import or Export Data
#'
#' Internal helper function to define a schema used when writing datasets.
#'
#' @param category Character string. Either `"export"` or `"import"`, indicating the data type.
#'
#' @return An `arrow::schema` object matching the specified category.
#'
#' @keywords internal
#' @noRd
create_schema <- function(category = c("export", "import")) {
  category <- match.arg(category)

  if(category == "export") {
    # Schema for exports
    return(arrow::schema(
      year = arrow::int32(),
      month = arrow::int32(),
      ncm = arrow::utf8(),
      state = arrow::utf8(),
      country_code = arrow::int32(),
      fob_value = arrow::int64(),
      kg = arrow::int64(),
      qt = arrow::int64()
    ))
  }

  if(category == "import") {
    # Schema for imports
    return(arrow::schema(
      year = arrow::int32(),
      month = arrow::int32(),
      ncm = arrow::utf8(),
      state = arrow::utf8(),
      country_code = arrow::int32(),
      fob_value = arrow::int64(),
      cif_value = arrow::int64(), # exportações não tem esse dado
      kg = arrow::int64(),
      qt = arrow::int64()
    ))
  }
}

#' Compare Local Database Date with last date available in API
#'
#' Checks if the local database is up-to-date compared to the API's last update.
#'
#' @param file_dir Character string. Path to the local Arrow dataset directory.
#'
#' @return Logical value. `TRUE` if the local dataset is up to date, `FALSE` otherwise.
#'
#' @keywords internal
#' @noRd
compare_local_db <- function(file_dir) {
  temp_date_api <- get_last_update()
  temp_date_local <- most_recent_date(file_dir = file_dir)

  if (temp_date_api == temp_date_local) {
    return(TRUE)
  }
  return(FALSE)
}

#' Get Last Available Update from API
#'
#' Queries the Comex Stat API to retrieve the most recent available update date.
#'
#' @return A character string in the format `"yyyy-mm"` representing the most recent update.
#'
#' @keywords internal
#' @noRd
get_last_update <- function() {
  url <- "https://api-comexstat.mdic.gov.br/general/dates/updated"

  response <- httr::GET(url)
  json_data <- suppressMessages(httr::content(response, as = "text"))

  last_update <- jsonlite::fromJSON(json_data, flatten = TRUE) |>
    purrr::pluck("data")

  paste0(last_update$year, "-", stringr::str_pad(last_update$monthNumber, 2, "left", "0"))
}

#' Get Most Recent Date from Local Dataset
#'
#' Extracts the most recent year and month available in a local Arrow dataset.
#'
#' @param file_dir Character string. Path to the local Arrow dataset directory.
#'
#' @return A character string in the format `"yyyy-mm"` representing the most recent local date.
#'
#' @keywords internal
#' @noRd
most_recent_date <- function(file_dir) {
  arrow::open_dataset(file_dir) |>
    dplyr::select(year, month) |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::filter(year == max(year)) |>
    dplyr::filter(month == max(month)) |>
    dplyr::mutate(month = stringr::str_pad(month, 2, side = "left", pad = "0")) |>
    dplyr::mutate(result = paste0(year, "-", month)) |>
    dplyr::pull(result)
}

#' Download Comex Stat year files with retry
#'
#' Downloads a file with up to 3 retry attempts if errors occur.
#'
#' @param link_download Character string. URL for the CSV file.
#' @param dir_file_download Character string. Local path to save the downloaded file.
#'
#' @return No return value. File is written to disk or an error is thrown after 3 failed attempts.
#'
#' @keywords internal
#' @noRd
download_cs_file <- function(link_download, dir_file_download) {
  year_from_link <- stringr::str_extract(link_download, "[0-9]{4}")
  sleep <- 5
  download_success <- FALSE

  for (attempt in 1:3) {
    tryCatch({
      httr::GET(
        link_download,
        httr::write_disk(dir_file_download, overwrite = TRUE),
        httr::progress()
      )
      download_success <- TRUE
      break
    },
    error = function(e) {
      message(glue::glue("Attempt {attempt} failed: {e$message}"))
      if (attempt < 3) Sys.sleep(sleep)
    })
  }
  if (!download_success) {
    stop(glue::glue("Failed to download {category} {year_from_link} after 3 attempts.\n"))
  }
}

#' Read and Process Import Data from CSV
#'
#' Reads a CSV file for import data and performs transformations.
#'
#' @param path Character string. File path to the downloaded import csv file.
#'
#' @return A `tibble` with cleaned and grouped import data.
#'
#' @keywords internal
#' @noRd
read_imports <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1",
    select = c("CO_ANO", "CO_MES", "CO_NCM", "SG_UF_NCM", "CO_PAIS",
               "KG_LIQUIDO", "QT_ESTAT", "VL_FOB", "VL_FRETE", "VL_SEGURO")
  ) |>
    janitor::clean_names() |>
    dplyr::rename(
      year = co_ano, month = co_mes, ncm = co_ncm, state = sg_uf_ncm,
      country_code = co_pais, kg = kg_liquido, qt = qt_estat, fob_value = vl_fob
    ) |>
    dplyr::mutate(across(c(fob_value, kg, qt, vl_frete, vl_seguro), as.numeric)) |>
    dplyr::group_by(year, month, ncm, state, country_code) |>
    dplyr::summarise(across(c(fob_value, vl_seguro, vl_frete, kg, qt), sum), .groups = "drop") |>
    dplyr::mutate(
      cif_value = fob_value + vl_seguro + vl_frete,
      ncm = stringr::str_pad(ncm, 8, "left", "0")
    ) |>
    dplyr::select(-vl_seguro, -vl_frete) |>
    dplyr::relocate(cif_value, .after = fob_value) |>
    dplyr::arrange(month)
}

#' Read and Process Export Data from CSV
#'
#' Reads a CSV file for export data and performs transformations.
#'
#' @param path Character string. File path to the export CSV file.
#'
#' @return A `tibble` with cleaned and grouped export data.
#'
#' @keywords internal
#' @noRd
read_exports <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1",
    select = c("CO_ANO", "CO_MES", "CO_NCM", "SG_UF_NCM",
               "CO_PAIS", "KG_LIQUIDO", "QT_ESTAT", "VL_FOB")
  ) |>
    janitor::clean_names() |>
    dplyr::rename(
      year = co_ano, month = co_mes, ncm = co_ncm, state = sg_uf_ncm,
      country_code = co_pais, kg = kg_liquido, qt = qt_estat, fob_value = vl_fob
    ) |>
    dplyr::mutate(across(c(fob_value, kg, qt), as.numeric)) |>
    dplyr::group_by(year, month, ncm, state, country_code) |>
    dplyr::summarise(across(c(fob_value, kg, qt), sum), .groups = "drop") |>
    dplyr::mutate(ncm = stringr::str_pad(ncm, 8, "left", "0")) |>
    dplyr::arrange(month)
}

#' Write Cleaned Data to Arrow Dataset
#'
#' Writes a dataset to disk in Arrow format, partitioned by year.
#'
#' @param x tibble. A `tibble` to be written.
#' @param path character string. Output directory for the dataset.
#' @param data_schema An `arrow::schema` to enforce during writing.
#'
#' @return No return value. Writes files to the specified path.
#'
#' @keywords internal
#' @noRd
write_cs_db <- function(x, path, data_schema) {
  df <- arrow::arrow_table(x)$cast(data_schema)
  arrow::write_dataset(df, path, partitioning = "year")
}

#' Build Database from Comex Stat CSV Link
#'
#' Downloads, reads, processes and writes Comex Stat data (import or export) to the appropriate Arrow dataset.
#'
#' @param link_download character string. URL to the Comex Stat CSV file.
#' @param db_dirs Named character vector with paths to `"import"` and `"export"` Arrow databases.
#' @param schemas Named list of Arrow schemas for `"import"` (imp) and `"export"` (exp) datasets.
#'
#' @return No return value. Data is written to disk.
#'
#' @keywords internal
#' @noRd
build_db <- function(link_download, db_dirs, schemas) {
  temp_dir <- file.path(withr::local_tempdir(), "temp.csv")
  year_from_link <- stringr::str_extract(link_download, "[0-9]{4}")
  category <- stringr::str_extract(link_download, "EXP|IMP") |>
    stringr::str_to_lower()

  message(glue::glue("Downloading {category} {year_from_link}\n"))
  download_cs_file(
    link_download = link_download,
    dir_file_download = temp_dir
  )

  if (category == "imp") {
    selected_data <- read_imports(temp_dir)
    write_cs_db(
      x = selected_data,
      path = stringr::str_subset(db_dirs, "imp"),
      data_schema = schemas[["imp"]]
    )
  } else if (category == "exp") {
    selected_data <- read_exports(temp_dir)
    write_cs_db(
      x = selected_data,
      path = stringr::str_subset(db_dirs, "exp"),
      data_schema = schemas[["exp"]]
    )
  }
  message(glue::glue("Download and data write for {category} {year_from_link} complete\n"))
}
