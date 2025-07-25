
compare_local_db <- function(file_dir) {
  temp_date_api <- get_last_update()
  temp_date_local <- most_recent_date(file_dir = file_dir)

  if (temp_date_api == temp_date_local) {
    return(TRUE)
  }
  return(FALSE)
}

get_last_update <- function() {
  url <- "https://api-comexstat.mdic.gov.br/general/dates/updated"

  response <- httr::GET(url)
  json_data <- suppressMessages(httr::content(response, as = "text"))

  last_update <- jsonlite::fromJSON(json_data, flatten = TRUE) |>
    purrr::pluck("data")

  paste0(last_update$year, "-", stringr::str_pad(last_update$monthNumber, 2, "left", "0"))
}


most_recent_date <- function(file_dir) {
  arrow::open_dataset(file_dir) |>
    dplyr::select(co_ano, co_mes) |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::filter(co_ano == max(co_ano)) |>
    dplyr::filter(co_mes == max(co_mes)) |>
    dplyr::mutate(co_mes = stringr::str_pad(co_mes, 2, side = "left", pad = "0")) |>
    dplyr::mutate(resultado = paste0(co_ano, "-", co_mes)) |>
    dplyr::pull(resultado)
}
