#' Função auxiliar para ler arquivo de importação baixado
#' 
#' @param path Character. Caminho do arquivo CSV a ser lido.
#' 
#' @return Um `tibble`.
ler_download_imp <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1",
    select = c("CO_ANO", "CO_MES", "CO_NCM", "SG_UF_NCM", "CO_PAIS",
               "KG_LIQUIDO", "QT_ESTAT", "VL_FOB", "VL_FRETE", "VL_SEGURO")
  ) %>% 
    janitor::clean_names() %>% 
    dplyr::mutate(across(c(vl_fob, kg_liquido, qt_estat, vl_frete, vl_seguro), as.numeric)) %>%
    dplyr::group_by(co_ano, co_mes, co_ncm, sg_uf_ncm, co_pais) %>%
    dplyr::summarise(across(c(vl_fob, vl_seguro, vl_frete, kg_liquido, qt_estat), sum), .groups = "drop") %>%
    dplyr::mutate(
      vl_cif = vl_fob + vl_seguro + vl_frete,
      co_ncm = str_pad(co_ncm, 8, "left", "0")
    ) %>%
    dplyr::select(-vl_seguro, -vl_frete) %>%
    dplyr::relocate(vl_cif, .after = vl_fob) %>%
    dplyr::left_join(paises, by = "co_pais") %>%
    dplyr::left_join(uf, by = "sg_uf_ncm") %>% 
    dplyr::select(-co_pais, -sg_uf_ncm) %>%
    dplyr::relocate(no_pais, .before = co_ncm) %>%
    dplyr::relocate(no_uf, .before = no_pais) %>%
    dplyr::arrange(co_mes)
}

#' Função auxiliar para ler arquivo de exportação baixado
#' 
#' @param path Character. Caminho do arquivo CSV a ser lido.
#' 
#' @return Um `tibble`.
ler_download_exp <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1",
    select = c("CO_ANO", "CO_MES", "CO_NCM", "SG_UF_NCM",
               "CO_PAIS", "KG_LIQUIDO", "QT_ESTAT", "VL_FOB")
  ) %>%
    janitor::clean_names() %>%
    dplyr::mutate(across(c(vl_fob, kg_liquido, qt_estat), as.numeric)) %>%
    dplyr::group_by(co_ano, co_mes, co_ncm, sg_uf_ncm, co_pais) %>%
    dplyr::summarise(across(c(vl_fob, kg_liquido, qt_estat), sum), .groups = "drop") %>%
    dplyr::mutate(co_ncm = str_pad(co_ncm, 8, "left", "0")) %>%
    dplyr::left_join(paises, by = "co_pais") %>%
    dplyr::left_join(uf, by = "sg_uf_ncm") %>% 
    dplyr::select(-co_pais, -sg_uf_ncm) %>%
    dplyr::relocate(no_pais, .before = co_ncm) %>%
    dplyr::relocate(no_uf, .before = no_pais) %>%
    dplyr::arrange(co_mes)
}

#' Baixa, trata e salva dados do Comex Stat na pasta database em formato Parquet
#'
#' Esta função faz o download de dados brutos do Comex Stat
#' a partir do link da base oficial. A funçao também limpa e organiza os dados
#'  conforme o tipo (exportação ou importação) e salva o resultado em formato
#' `.parquet` na pasta local database.
#'
#' O comportamento da função é adaptado com base no tipo de dado (`EXP` ou `IMP`)
#' identificado no link. A base é agregada por ano, mês, UF, NCM, país, valor fob em
#' dólares, peso em quilograma líquido e quantidade estatística.No caso de 
#' importações, também temos o valor CIF em dólares, além do FOB.
#'
#' @param link_download String. URL de download direto para o arquivo CSV de dados do Comex Stat.
#'
#' @return Nenhum valor é retornado. Os dados tratados são gravados diretamente
#' em arquivos `.parquet` no caminho especificado na pasta database.
download_dados_cs <- function(link_download) {
  tipo <- str_extract(link_download, "EXP|IMP") %>% str_to_lower()
  ano_link <- str_extract(link_download, "[0-9]{4}")
  dir_file_download <- file.path("temp", "temp.csv")
  sleep <- 5 # tempo para tentar download novamente
  sucesso_download <- FALSE
  
  for (tentativa in 1:3) {
    tryCatch({
      httr::GET(
        link_download, 
        httr::write_disk(dir_file_download, overwrite = TRUE), 
        httr::progress()
        )
      sucesso_download <- TRUE
      break
    },
    error = function(e) {
      message(glue::glue("Tentativa {tentativa} falhou: {e$message}"))
      if (tentativa < 3) Sys.sleep(sleep)
    })
  }
  
  if (!sucesso_download) {
    stop(glue::glue("Falha no download de {tipo}_{ano_link} após 3 tentativas.\n"))
  }
  
  if (tipo == "imp") {
    path <- diretorio_imp
    
    x <- ler_download_imp(dir_file_download)
    x <- arrow_table(x)$cast(schema_comexstat_imp)
    
  } else if (tipo == "exp") {
    path <- diretorio_exp
    
    x <- ler_download_exp(dir_file_download)
    x <- arrow_table(x)$cast(schema_comexstat_exp)
  }
  
  write_dataset(x, path, partitioning = "co_ano")
  message(glue::glue("Download de {tipo}_{ano_link} ok"))
}

#' Baixa, trata e salva dados do Comex Stat no OneDrive
#'
#' Esta função faz o download de dados brutos do Comex Stat
#' a partir do link da base oficial. A funçao também limpa e organiza os dados
#'  conforme o tipo (exportação ou importação) e salva o resultado em formato
#' `.parquet` nas pastas definidas do OneDrive.
#'
#' O comportamento da função é adaptado com base no tipo de dado (`EXP` ou `IMP`)
#' identificado no link. A base é agregada por ano, mês, UF, NCM, país, valor fob em
#' dólares, peso em quilograma líquido e quantidade estatística. No caso de 
#' importações, também temos o valor CIF em dólares, além do FOB.
#'
#' @param link_download String. URL de download direto para o arquivo CSV de dados do Comex Stat.
#'
#' @return Nenhum valor é retornado. Os dados tratados são gravados diretamente
#' em arquivos `.parquet` no caminho especificado pelo usuário no OneDrive.
download_dados_cs_onedrive <- function(link_download) {
  tipo <- str_extract(link_download, "EXP|IMP") %>% str_to_lower()
  ano_link <- str_extract(link_download, "[0-9]{4}")
  dir_file_download <- file.path("temp", "temp.csv")
  sleep <- 5 # tempo para tentar download novamente
  sucesso_download <- FALSE
  
  for (tentativa in 1:3) {
    tryCatch({
      httr::GET(
        link_download, 
        httr::write_disk(dir_file_download, overwrite = TRUE), 
        httr::progress()
      )
      sucesso_download <- TRUE
      break
    },
    error = function(e) {
      message(glue::glue("Tentativa {tentativa} falhou: {e$message}"))
      if (tentativa < 3) Sys.sleep(sleep)
    })
  }
  
  if (!sucesso_download) {
    stop(glue::glue("Falha no download de {tipo}_{ano_link} após 3 tentativas.\n"))
  }
  
  if (tipo == "imp") {
    path <- Sys.getenv("import")
    
    x <- ler_download_imp(dir_file_download)
    x <- arrow_table(x)$cast(schema_comexstat_imp)
    
  } else if (tipo == "exp") {
    path <- Sys.getenv("export")
    
    x <- ler_download_exp(dir_file_download)
    x <- arrow_table(x)$cast(schema_comexstat_exp)
  }
  
  write_dataset(x, path, partitioning = "co_ano")
  message(glue::glue("Download de {tipo}_{ano_link} ok"))
}
