achar_link_tabela_aux <- function(page, nome){

  page |>
    rvest::html_elements("table tr td a") |>
    rvest::html_attr("href") |>
    stringr::str_subset(glue::glue("{nome}.csv"))
}

cria_esquema <- function(tipo = c("export", "import")) {
  tipo <- match.arg(tipo)
  
  if(tipo == "export") {
    # Cria "schema" para base de dados de exportação
    return(arrow::schema(
      co_ano = arrow::int32(),
      co_mes = arrow::int32(),
      no_uf = arrow::utf8(),
      no_pais = arrow::utf8(),
      co_ncm = arrow::utf8(),
      vl_fob = arrow::int64(),
      kg_liquido = arrow::int64(),
      qt_estat = arrow::int64()
    ))
  }
  
  if(tipo == "import") {
    # Cria "schema" para base de dados de importação
    return(arrow::schema(
      co_ano = arrow::int32(),
      co_mes = arrow::int32(),
      no_uf = arrow::utf8(),
      no_pais = arrow::utf8(),
      co_ncm = arrow::utf8(),
      vl_fob = arrow::int64(),
      vl_cif = arrow::int64(), # exportações não tem esse dado
      kg_liquido = arrow::int64(),
      qt_estat = arrow::int64()
    ))
  }
}

gera_base <- function(
    dest_dir, # diretório onde a base será criada
    ano_inicial, # ano inicial da base
    timeout = 2000 # tempo necessário para download
) {
  
  # Link da página do Comex Stat para baixar dados brutos
  link_cs <-
    "https://www.gov.br/mdic/pt-br/assuntos/comercio-exterior/estatisticas/base-de-dados-bruta"
  
  # Definir tempo limite para download. É necessário definir um tempo maior, uma
  # vez que é possível que o download demore mais do que o esperado. Alterar caso
  # seja necessário um tempo maior.
  options(timeout = timeout)
  
  # cria intervalo de anos a serem excluídos da base local
  intervalo_para_exclusao <- 1997:(ano_inicial - 1)
  
  # obter data corrente
  data_corrente <- Sys.Date()
  
  # obtém ano corrente e passa para classe numérica. Isso é necessário
  # para poder subtrair do ano
  ano_corrente <- stringr::str_sub(data_corrente, 1, 4) |> 
    as.numeric()
  
  # obter vetor dos anos da série do comex stat
  serie_cstat <- 1997:ano_corrente # 1997 é o início da serie no comex stat
  
  # obter anos para série do comex stat local
  serie_cstat_desejada <- setdiff(serie_cstat, intervalo_para_exclusao)
  
  # Diretórios para base 
  diretorio_exp <- file.path(dest_dir, "export")
  diretorio_imp <- file.path(dest_dir, "import")
  
  diretorios <- c(diretorio_exp, diretorio_imp)
  
  # Diretório para pasta temporária
  temp <- "temp"
  
  # Cria pasta temp, caso não exista
  if(!file.exists(temp)) {
    
    dir.create(temp, recursive = TRUE)
    cat("Pasta temp criada com sucesso\n")
    
  }
  
  # cria esquemas
  schema_comexstat_exp <- cria_esquema(tipo = "export")
  schema_comexstat_imp <- cria_esquema(tipo = "import")
  
  schemas_bases <- list(exp = schema_comexstat_exp, imp = schema_comexstat_imp)
  
  # cria subpasta para dados de exportação
  dir.create(
    diretorio_exp,
    recursive = TRUE
  )
  
  # cria subpasta para dados de exportação
  dir.create(
    diretorio_imp,
    recursive = TRUE
  )
  cat("Subpastas export e import criadas com sucesso na pasta database\n")
  
  anos_para_baixar <- paste0(serie_cstat_desejada, collapse = "|")
  
  # obter dados html de link_cs
  page <- rvest::read_html(link_cs)
  
  # obter links relevantes para download dos dados ano a ano
  links_download <- page |>
    rvest::html_elements("table tr td a") |>
    rvest::html_attr("href") |>
    stringr::str_subset("/ncm/") |>
    stringr::str_subset("COMPLETA|CONFERENCIA", negate = TRUE) |>
    stringr::str_subset(anos_para_baixar)
  
  link_download_paises <- achar_link_tabela_aux(page, "PAIS")
  link_download_uf <- achar_link_tabela_aux(page, "UF")
  
  # Define local do diretório temporário de arquivos
  dir_temp_pais <- file.path(temp, "pais.csv")
  dir_temp_uf <- file.path(temp, "uf.csv")
  
  # baixar correlação pais
  download_tabela_aux(
    link_download_paises,
    dir_temp_pais
  )
  
  # baixar correlação uf
  download_tabela_aux(
    link_download_uf,
    dir_temp_uf
  )
  
  # abrir/trazer dados de país para o R
  paises <- ler_tabela_aux(dir_temp_pais) |> 
    dplyr::select(co_pais, no_pais)
  
  # abrir/trazer dados de uf para o R
  uf <- ler_tabela_aux(dir_temp_uf) |> 
    dplyr::select(sg_uf_ncm = sg_uf, no_uf)
  
  tabelas_auxiliares <- list(
    paises = paises,
    uf = uf
  )
  
  # aplicar função download_dados_cs para vetor links_download
  links_download |>
    purrr::walk(~ download_dados_cs(
      .x,
      dirs = diretorios,
      tab_aux = tabelas_auxiliares,
      schemas = schemas_bases))
  
  # apagar arquivos baixados
  file.remove(file.path(temp, "temp.csv"))
  file.remove(dir_temp_pais)
  file.remove(dir_temp_uf)
  
}

atualiza_base <- function(
    dest_dir, # diretório onde a base será criada
    ano_inicial = NULL, # ano inicial da base
    timeout = 2000 # tempo necessário para download
) {
  # Link da página do Comex Stat para baixar dados brutos
  link_cs <-
    "https://www.gov.br/mdic/pt-br/assuntos/comercio-exterior/estatisticas/base-de-dados-bruta"
  
  # Definir tempo limite para download. É necessário definir um tempo maior, uma
  # vez que é possível que o download demore mais do que o esperado. Alterar caso
  # seja necessário um tempo maior.
  options(timeout = timeout)
  
  # Diretórios para base 
  diretorio_exp <- file.path(dest_dir, "export")
  diretorio_imp <- file.path(dest_dir, "import")
  
  diretorios <- c(diretorio_exp, diretorio_imp)
  
  # obter anos disponíveis dos dados na pasta de exportações
  anos_disponiveis_exp <- try(
    arrow::open_dataset(diretorio_exp) |> 
      dplyr::select(co_ano) |> 
      dplyr::distinct() |> 
      dplyr::collect() |> 
      dplyr::pull(co_ano) |> 
      sort(),
    silent = TRUE
  )
  
  # obter anos disponíveis dos dados na pasta de importações
  anos_disponiveis_imp <- try(
    arrow::open_dataset(diretorio_imp) |> 
      dplyr::select(co_ano) |> 
      dplyr::distinct() |> 
      dplyr::collect() |> 
      dplyr::pull(co_ano) |> 
      sort(),
    silent = TRUE)
  
  # caso haja alguma falha na primeira execução lançamos erro
  if (
    inherits(anos_disponiveis_exp, "try-error") ||
    inherits(anos_disponiveis_imp, "try-error")
  ) {
    stop("A base foi gerada com erro. Não é possível atualizar.
         Tente executar a função gera_base\n")
  }
  
  # obter ano inicial da base
  if (is.null(ano_inicial)) {
    ano_min_exp <- min(anos_disponiveis_exp) |>
      unique()
    ano_min_imp <- min(anos_disponiveis_exp) |>
      unique()
    
    if (ano_min_exp == ano_min_imp) {
      ano_inicial <- ano_min_exp
    }
    
    if(ano_min_exp > ano_min_imp) {
      ano_inicial <- ano_min_imp
    } else {
      ano_inicial <- ano_min_exp
    }
  }
  
  
  # cria intervalo de anos a serem excluídos da base local
  intervalo_para_exclusao <- 1997:(ano_inicial - 1)
  
  # obter data corrente
  data_corrente <- Sys.Date()
  
  # obtém ano corrente e passa para classe numérica. Isso é necessário
  # para poder subtrair do ano
  ano_corrente <- stringr::str_sub(data_corrente, 1, 4) |> 
    as.numeric()
  
  # obter vetor dos anos da série do comex stat
  serie_cstat <- 1997:ano_corrente # 1997 é o início da serie no comex stat
  
  # obter anos para série do comex stat local
  serie_cstat_desejada <- setdiff(serie_cstat, intervalo_para_exclusao)
  
  # Diretório para pasta temporária
  temp <- "temp"
  
  # Cria pasta temp, caso não exista
  if(!file.exists(temp)) {
    
    dir.create(temp, recursive = TRUE)
    cat("Pasta temp criada com sucesso\n")
    
  }
  
  # cria esquemas
  schema_comexstat_exp <- cria_esquema(tipo = "export")
  schema_comexstat_imp <- cria_esquema(tipo = "import")
  
  schemas_bases <- list(exp = schema_comexstat_exp, imp = schema_comexstat_imp)
  
  # selecionar anos que nao precisam ser baixados, desde que estejam presentes
  # tanto em exportações como em importações
  excluir_anos_download <- intersect(anos_disponiveis_exp, anos_disponiveis_imp)
  
  # obter período dos últimos dados disponíveis na base local
  atualizacao_local_imp <- arrow::open_dataset(diretorio_imp) |> 
    dplyr::select(co_ano, co_mes) |> 
    dplyr::distinct() |> 
    dplyr::collect() |> 
    dplyr::filter(max(co_ano) == co_ano) |> 
    dplyr::filter(max(co_mes) == co_mes) |> 
    dplyr::mutate(co_mes = stringr::str_pad(co_mes, width = 2, side = 'left', pad = '0')) |> 
    tidyr::unite(col = "atualizacao", co_ano, co_mes, sep = "-") |> 
    dplyr::pull(atualizacao)
  
  atualizacao_local_exp <- arrow::open_dataset(diretorio_exp) |> 
    dplyr::select(co_ano, co_mes) |> 
    dplyr::distinct() |> 
    dplyr::collect() |> 
    dplyr::filter(max(co_ano) == co_ano) |> 
    dplyr::filter(max(co_mes) == co_mes) |> 
    dplyr::mutate(co_mes = stringr::str_pad(co_mes, width = 2, side = 'left', pad = '0')) |> 
    tidyr::unite(col = "atualizacao", co_ano, co_mes, sep = "-") |> 
    dplyr::pull(atualizacao)
  
  # testa se bases estão atualizadas
  teste_base_export <- compara_base_local(diretorio = diretorio_exp)
  teste_base_import <- compara_base_local(diretorio = diretorio_imp)
  
  # ano_update_base_oficial é o ano da última atulização dos dados no site do comex stat
  ano_update_base_oficial <- stringr::str_sub(get_last_update(), 1, 4)
  
  # ano_update_base_local é o último ano de atualização da base do comex stat
  # na pasta database
  ano_update_base_local <- stringr::str_sub(atualizacao_local_imp, 1, 4)
  
  # Além dos anos já definidos para exlcusão anteriormente, remover ano corrente
  # e ano imediatamente anterior caso não esteja atualizado
  excluir_anos_download <- 
    excluir_anos_download[!excluir_anos_download %in% ano_update_base_local:ano_update_base_oficial]
  
  # Selecionar anos que serão atualizados/baixados nas base
  anos_para_baixar <- setdiff(serie_cstat_desejada, excluir_anos_download)
  
  # testa se foram solicitados anos anteriores aos que estão disponíveis
  # na base local
  teste_anos_anteriores <- stringr::str_detect(
    anos_para_baixar,
    ano_update_base_oficial,
    negate = TRUE
  ) %>% 
    any()
  
  if(teste_base_export && teste_base_import && !teste_anos_anteriores) {
    # se a condição for verdadeira, a base está atualizada
    stop("Bases atualizadas")
  }
  
  cat(glue::glue("Base local do Comex Stat desatualizada. Atualizando...\n"))
  
  # cria regex para selecão de links
  anos_para_baixar <- paste0(anos_para_baixar, collapse = "|")
  
  # obter dados html de link_cs
  page <- rvest::read_html(link_cs)
  
  # obter links relevantes para download dos dados ano a ano
  links_download <- page |>
    rvest::html_elements("table tr td a") |>
    rvest::html_attr("href") |>
    stringr::str_subset("/ncm/") |>
    stringr::str_subset("COMPLETA|CONFERENCIA", negate = TRUE) |>
    stringr::str_subset(anos_para_baixar)
  
  link_download_paises <- achar_link_tabela_aux(page, "PAIS")
  link_download_uf <- achar_link_tabela_aux(page, "UF")
  
  # Define local do diretório temporário de arquivos
  dir_temp_pais <- file.path(temp, "pais.csv")
  dir_temp_uf <- file.path(temp, "uf.csv")
  
  # baixar correlação pais
  download_tabela_aux(
    link_download_paises,
    dir_temp_pais
  )
  
  # baixar correlação uf
  download_tabela_aux(
    link_download_uf,
    dir_temp_uf
  )
  
  # abrir/trazer dados de país para o R
  paises <- ler_tabela_aux(dir_temp_pais) |> 
    dplyr::select(co_pais, no_pais)
  
  # abrir/trazer dados de uf para o R
  uf <- ler_tabela_aux(dir_temp_uf) |> 
    dplyr::select(sg_uf_ncm = sg_uf, no_uf)
  
  tabelas_auxiliares <- list(
    paises = paises,
    uf = uf
  )
  
  # aplicar função download_dados_cs para vetor links_download
  links_download |>
    purrr::walk(~ download_dados_cs(.x, dirs = diretorios, tab_aux = tabelas_auxiliares))
  
  # apagar arquivos baixados
  file.remove(file.path(temp, "temp.csv"))
  file.remove(dir_temp_pais)
  file.remove(dir_temp_uf)
}