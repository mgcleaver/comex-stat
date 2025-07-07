#' Baixa, trata e salva dados do Comex Stat na pasta database em formato Parquet
#'
#' Esta função faz o download de dados brutos do Comex Stat
#' a partir do link da base oficial. A funçao também limpa e organiza os dados
#'  conforme o tipo (exportação ou importação) e salva o resultado em formato
#' `.parquet` na pasta local database.
#'
#' O comportamento da função é adaptado com base no tipo de dado (`EXP` ou `IMP`)
#' identificado no link. A base é agregada por ano, mês, NCM, país, valor fob em
#' dólares, peso em quilograma líquido e quantidade estatística.No caso de 
#' importações, também temos o valor CIF em dólares, além do FOB.
#'
#' @param link_download String. URL de download direto para o arquivo CSV de dados do Comex Stat.
#' Deve conter no nome o tipo (`EXP` ou `IMP`) e o ano, por exemplo: `"EXP_2023.csv"`.
#'
#' @return Nenhum valor é retornado. Os dados tratados são gravados diretamente
#' em arquivos `.parquet` no caminho especificado na pasta database.
#'
#' @details
#' A função espera que os dados brutos estejam codificados em `Latin-1` e com colunas
#' padronizadas do Comex Stat. A estrutura de pastas usadas localmente segue:
#' `"database/import"` ou `"database/export"`.
#'
#' @examples
#' \dontrun{
#' get_comexstat(
#'   link_download = "https://comexstat.mdic.gov.br/download/EXP_2023.csv"
#' )
#' }
download_dados_cs <- function(link_download) {
  tipo <- str_extract(link_download, "EXP|IMP") %>% str_to_lower()
  ano_link <- str_extract(link_download, "[0-9]{4}")
  dir_file_download <- file.path("temp", "temp.csv")
  
  sucesso_download <- FALSE
  
  for (tentativa in 1:3) {
    tryCatch({
      download.file(url = link_download, destfile = dir_file_download, mode = "wb")
      sucesso_download <- TRUE
      break
    },
    error = function(e) {
      message(glue::glue("Tentativa {tentativa} falhou: {e$message}"))
      if (tentativa < 3) Sys.sleep(5)
    })
  }
  
  if (!sucesso_download) {
    stop(glue::glue("Falha no download de {tipo}_{ano_link} após 3 tentativas.\n"))
  }
  
  if (tipo == "imp") {
    path <- diretorio_imp
    
    x <- fread(
      dir_file_download,
      encoding = "Latin-1",
      select = c("CO_ANO", "CO_MES", "CO_NCM", "CO_PAIS", "KG_LIQUIDO",
                 "QT_ESTAT", "VL_FOB", "VL_FRETE", "VL_SEGURO")
    ) %>% 
      clean_names() %>% 
      mutate(across(c(vl_fob, kg_liquido, qt_estat, vl_frete, vl_seguro), as.numeric)) %>%
      group_by(co_ano, co_mes, co_ncm, co_pais) %>%
      summarise(across(c(vl_fob, vl_seguro, vl_frete, kg_liquido, qt_estat), sum), .groups = "drop") %>%
      mutate(
        vl_cif = vl_fob + vl_seguro + vl_frete,
        co_ncm = str_pad(co_ncm, 8, "left", "0")
      ) %>%
      select(-vl_seguro, -vl_frete) %>%
      relocate(vl_cif, .after = vl_fob) %>%
      left_join(paises, by = "co_pais") %>%
      select(-co_pais) %>%
      relocate(no_pais, .before = co_ncm) %>%
      arrange(co_mes)
    
  } else if (tipo == "exp") {
    path <- diretorio_exp
    
    x <- fread(
      dir_file_download,
      encoding = "Latin-1",
      select = c("CO_ANO", "CO_MES", "CO_NCM", "CO_PAIS", "KG_LIQUIDO", "QT_ESTAT", "VL_FOB")
    ) %>%
      clean_names() %>%
      mutate(across(c(vl_fob, kg_liquido, qt_estat), as.numeric)) %>%
      group_by(co_ano, co_mes, co_ncm, co_pais) %>%
      summarise(across(c(vl_fob, kg_liquido, qt_estat), sum), .groups = "drop") %>%
      mutate(co_ncm = str_pad(co_ncm, 8, "left", "0")) %>%
      left_join(paises, by = "co_pais") %>%
      select(-co_pais) %>%
      relocate(no_pais, .before = co_ncm) %>%
      arrange(co_mes)
  }
  
  write_dataset(x, path, partitioning = "co_ano")
  return(glue::glue("Download de {tipo}_{ano_link} ok"))
}

#' Baixa, trata e salva dados do Comex Stat no OneDrive
#'
#' Esta função faz o download de dados brutos do Comex Stat
#' a partir do link da base oficial. A funçao também limpa e organiza os dados
#'  conforme o tipo (exportação ou importação) e salva o resultado em formato
#' `.parquet` nas pastas definidas do OneDrive.
#'
#' O comportamento da função é adaptado com base no tipo de dado (`EXP` ou `IMP`)
#' identificado no link. A base é agregada por ano, mês, NCM, país, valor fob em
#' dólares, peso em quilograma líquido e quantidade estatística.No caso de 
#' importações, também temos o valor CIF em dólares, além do FOB.
#'
#' @param link_download String. URL de download direto para o arquivo CSV de dados do Comex Stat.
#' Deve conter no nome o tipo (`EXP` ou `IMP`) e o ano, por exemplo: `"EXP_2023.csv"`.
#'
#' @return Nenhum valor é retornado. Os dados tratados são gravados diretamente
#' em arquivos `.parquet` no caminho especificado pelo usuário no OneDrive.
download_dados_cs_onedrive <- function(link_download) {
  tipo <- str_extract(link_download, "EXP|IMP") %>% str_to_lower()
  ano_link <- str_extract(link_download, "[0-9]{4}")
  dir_file_download <- file.path("temp", "temp.csv")
  
  sucesso_download <- FALSE
  
  for (tentativa in 1:3) {
    tryCatch({
      download.file(url = link_download, destfile = dir_file_download, mode = "wb")
      sucesso_download <- TRUE
      break
    },
    error = function(e) {
      message(glue::glue("Tentativa {tentativa} falhou: {e$message}"))
      if (tentativa < 3) Sys.sleep(5)
    })
  }
  
  if (!sucesso_download) {
    stop(glue::glue("Falha no download de {tipo}_{ano_link} após 3 tentativas.\n"))
  }
  
  if (tipo == "imp") {
    path <- Sys.getenv("import")
    
    x <- fread(
      dir_file_download,
      encoding = "Latin-1",
      select = c("CO_ANO", "CO_MES", "CO_NCM", "CO_PAIS", "KG_LIQUIDO",
                 "QT_ESTAT", "VL_FOB", "VL_FRETE", "VL_SEGURO")
    ) %>% 
      clean_names() %>% 
      mutate(across(c(vl_fob, kg_liquido, qt_estat, vl_frete, vl_seguro), as.numeric)) %>%
      group_by(co_ano, co_mes, co_ncm, co_pais) %>%
      summarise(across(c(vl_fob, vl_seguro, vl_frete, kg_liquido, qt_estat), sum), .groups = "drop") %>%
      mutate(
        vl_cif = vl_fob + vl_seguro + vl_frete,
        co_ncm = str_pad(co_ncm, 8, "left", "0")
      ) %>%
      select(-vl_seguro, -vl_frete) %>%
      relocate(vl_cif, .after = vl_fob) %>%
      left_join(paises, by = "co_pais") %>%
      select(-co_pais) %>%
      relocate(no_pais, .before = co_ncm) %>%
      arrange(co_mes)
    
  } else if (tipo == "exp") {
    path <- Sys.getenv("export")
    
    x <- fread(
      dir_file_download,
      encoding = "Latin-1",
      select = c("CO_ANO", "CO_MES", "CO_NCM", "CO_PAIS", "KG_LIQUIDO", "QT_ESTAT", "VL_FOB")
    ) %>%
      clean_names() %>%
      mutate(across(c(vl_fob, kg_liquido, qt_estat), as.numeric)) %>%
      group_by(co_ano, co_mes, co_ncm, co_pais) %>%
      summarise(across(c(vl_fob, kg_liquido, qt_estat), sum), .groups = "drop") %>%
      mutate(co_ncm = str_pad(co_ncm, 8, "left", "0")) %>%
      left_join(paises, by = "co_pais") %>%
      select(-co_pais) %>%
      relocate(no_pais, .before = co_ncm) %>%
      arrange(co_mes)
  }
  
  write_dataset(x, path, partitioning = "co_ano")
  return(glue::glue("Download de {tipo}_{ano_link} ok"))
}
