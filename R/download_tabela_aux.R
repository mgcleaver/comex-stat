
download_tabela_aux <- function(url, path) {
  resp <- httr::GET(url, httr::write_disk(path, overwrite = TRUE), httr::progress())

  if (httr::http_error(resp)) {
    stop("Falha no download: ", httr::http_status(resp)$message)
  }

  if (!file.exists(path) || file.info(path)$size == 0) {
    stop("Download falhou: arquivo não existe ou está vazio.")
  }
  message(glue::glue("Download de tabela temporária ok\n"))
}

ler_tabela_aux <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1"
  ) |>
    janitor::clean_names() |>
    tibble::as_tibble()
}
