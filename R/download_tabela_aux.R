#' Baixa uma tabela auxiliar do comex stat
#'
#' Realiza o download de um arquivo a partir de uma URL, salvando-o no caminho especificado.
#' A função usa `httr` para garantir que a requisição HTTP foi bem-sucedida e lança erro
#' caso o download falhe ou o arquivo salvo esteja corrompido.
#'
#' @param url Character. URL do arquivo a ser baixado.
#' @param path Character. Caminho completo (incluindo nome do arquivo) onde o arquivo será salvo.
#'
#' @return Nada. A função lança erro se o download falhar. Caso contrário, apenas salva o arquivo.
download_tabela_aux <- function(url, path) {
  resp <- httr::GET(url, httr::write_disk(path, overwrite = TRUE), httr::progress())
  
  if (httr::http_error(resp)) {
    stop("Falha no download: ", httr::http_status(resp)$message)
  }
  
  if (!file.exists(path) || file.info(path)$size == 0) {
    stop("Download falhou: arquivo não existe ou está vazio.")
  }
  message(glue::glue("Download ok\n"))
}

#' Lê uma tabela auxiliar do disco, aplica limpeza de nomes e transforma em tibble
#'
#' Esta função lê um arquivo previamente baixado
#' usando codificação `Latin-1`, aplica a limpeza dos nomes das colunas com `janitor::clean_names()`,
#' e retorna o resultado como um `tibble`.
#'
#' @param path Character. Caminho do arquivo local a ser lido (incluindo a extensão).
#'
#' @return Um `tibble`.
ler_tabela_aux <- function(path) {
  fread(
    path,
    encoding = "Latin-1"
  ) %>%
    clean_names() %>%
    as_tibble()
}
