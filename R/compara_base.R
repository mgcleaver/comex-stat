#' Verifica se a base local está atualizada em relação ao Comex Stat
#'
#' Compara a data do último dado disponível na API pública do Comex Stat com
#' a data mais recente presente na base local (armazenada na pasta `database`).
#'
#' @param tipo Character. Tipo de dado a ser verificado: `"export"` ou `"import"`.
#'
#' @return Logical. Retorna `TRUE` se a base local estiver atualizada em relação
#' à API e `FALSE` caso contrário.
compara_base_local <- function(diretorio) {
  tipo <- match.arg(tipo)
  
  temp_date_api <- get_last_update()
  temp_date_local <- ultimo_dado(diretorio = tipo)
  
  if (temp_date_api == temp_date_local) {
    return(TRUE)
  }
  return(FALSE)
}

#' Obtém a data mais recente disponível na API do Comex Stat
#'
#' Consulta a API pública do Comex Stat para obter o ano e o mês mais recentes
#' com dados disponíveis, no formato `"yyyy-mm"`.
#'
#' A consulta é feita à URL:
#' \url{https://api-comexstat.mdic.gov.br/general/dates/updated}
#'
#' @return Uma string no formato `"yyyy-mm"` representando a última atualização da API.
#'
#' @examples
#' get_last_update()
get_last_update <- function() {
  url <- "https://api-comexstat.mdic.gov.br/general/dates/updated"
  
  response <- httr::GET(url)
  json_data <- suppressMessages(httr::content(response, as = "text"))
  
  last_update <- jsonlite::fromJSON(json_data, flatten = TRUE) |>
    purrr::pluck("data")
  
  paste0(last_update$year, "-", stringr::str_pad(last_update$monthNumber, 2, "left", "0"))
}

#' Retorna o ano-mês mais recente disponível da base local
#'
#' Acessa os arquivos armazenados localmente em `database/{tipo}` e retorna
#' o ano e mês mais recentes disponíveis, no formato `"yyyy-mm"`.
#'
#' @param diretorio Character. Caminho para o diretório da base local.
#' O padrão é `"database"`.
#' @param tipo Character. Tipo de dado a ser consultado: `"export"` ou `"import"`.
#'
#' @return Uma string no formato `"yyyy-mm"` representando o dado mais recente da base local.
ultimo_dado <- function(diretorio) {
  arrow::open_dataset(diretorio) |>
    dplyr::select(co_ano, co_mes) |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::filter(co_ano == max(co_ano)) |>
    dplyr::filter(co_mes == max(co_mes)) |>
    dplyr::mutate(co_mes = stringr::str_pad(co_mes, 2, side = "left", pad = "0")) |>
    dplyr::mutate(resultado = paste0(co_ano, "-", co_mes)) |>
    dplyr::pull(resultado)
}
