# Baixa, atualiza e organiza dados do Comex Stat no OneDrive
# Obs. Para organizar a base no OneDrive é preciso fazer algumas configurações
# antes. Ler README para instruções mais detalhadas.

library(arrow)
library(dplyr)
library(tidyr)
library(stringr)
library(rvest)
library(data.table)
library(janitor)
library(purrr)
source("R/compara_base.R", encoding = "UTF-8")
source("R/download_dados_cs.R", encoding = "UTF-8")

# Configuração inicial ----------------------------------------------------

# Link da página do Comex Stat para baixar dados brutos
link_cs <- 
  "https://www.gov.br/mdic/pt-br/assuntos/comercio-exterior/estatisticas/base-de-dados-bruta"

# Definir tempo limite para download. É necessário definir um tempo maior, uma
# vez que é possível que o download demore mais do que o esperado. Alterar caso
# seja necessário um tempo maior.
options(timeout = 2000)

# Definimos ano inicial da base (pode começar a partir de 1997, primeiro
# ano da base do Comex Stat). No caso deste script começamos em 2015, mas caso
# seja de interesse pode-se começar em um ano anterior a 2015. Basta modificar
# o parâmetro ano_inicial para o ano desejado.
ano_inicial <- 2015

# cria intervalo de anos a serem excluídos da base
intervalo_para_exclusao <- 1997:(ano_inicial - 1)

# obter data corrente
data_corrente <- Sys.Date()

# obtém ano corrente e passa para classe numérica. Isso é necessário
# para poder subtrair do ano
ano_corrente <- str_sub(data_corrente, 1, 4) %>% 
  as.numeric()

# obter vetor dos anos da série do comex stat
serie_cstat <- 1997:ano_corrente # 1997 é o início da serie no comex stat

# obter anos para série do comex stat local
serie_cstat_desejada <- setdiff(serie_cstat, intervalo_para_exclusao)

# verifica se variáveis de ambiente estão configuradas
var_ambiente_import <- Sys.getenv("import")
var_ambiente_export <- Sys.getenv("export")

# impede a execução deste script se variáveis de ambiente não estiverem definidas
if(var_ambiente_import == "" || var_ambiente_export == "") {
  stop("É preciso configurar variável de ambiente de export e/ou import. Leia README")
}

# Diretório para pasta temporária
temp <- "temp"

# Cria pasta temp, caso não exista
if(!file.exists(temp)) {
  
  dir.create(temp, recursive = TRUE)
  cat("Pasta temp criada com sucesso\n")
  
}

# Cria "schema" para base de dados de exportação
schema_comexstat_exp <- schema(
  co_ano = int32(),
  co_mes = int32(),
  no_pais = utf8(),
  co_ncm = utf8(),
  vl_fob = int64(),
  kg_liquido = int64(),
  qt_estat = int64()
)

# Cria "schema" para base de dados de importação
schema_comexstat_imp <- schema(
  co_ano = int32(),
  co_mes = int32(),
  no_pais = utf8(),
  co_ncm = utf8(),
  vl_fob = int64(),
  vl_cif = int64(), # exportações não tem esse dado
  kg_liquido = int64(),
  qt_estat = int64()
)

# checa se existem dados no onedrive
teste_import <- open_dataset(var_ambiente_import) %>% 
  head() %>% 
  collect()

if(nrow(teste_import) == 0) {
  # definir quais anos serão baixados na base
  anos_para_baixar <- paste0(serie_cstat_desejada, collapse = "|")
  primeira_execucao <- TRUE 
  
} else {
  
  primeira_execucao <- FALSE
  sair_do_if <- FALSE
  
  # obter anos disponíveis dos dados na pasta de exportações
  anos_disponiveis_exp <- try(
    open_dataset(var_ambiente_export) %>% 
      select(co_ano) %>% 
      distinct() %>% 
      collect() %>% 
      pull(co_ano) %>% 
      sort(),
    silent = TRUE
  )
  
  # obter anos disponíveis dos dados na pasta de importações
  anos_disponiveis_imp <- try(
    open_dataset(var_ambiente_import) %>% 
      select(co_ano) %>% 
      distinct() %>% 
      collect() %>% 
      pull(co_ano) %>% 
      sort(),
    silent = TRUE
  )
  
  # caso haja alguma falha na primeira execução retomamos os valores
  # da primeira execução para baixar tudo novamente
  if (
    inherits(anos_disponiveis_exp, "try-error") ||
    inherits(anos_disponiveis_imp, "try-error")
  ) {
    primeira_execucao <- TRUE
    anos_para_baixar <- paste0(serie_cstat_desejada, collapse = "|")
    
    # interrompemos codigo do bloco if subsequente
    sair_do_if <- TRUE
  }
  
  if (!sair_do_if) {
    
    # selecionar anos que não precisam ser baixados, desde que estejam presentes
    # tanto em exportações como em importações
    excluir_anos_download <- intersect(anos_disponiveis_exp, anos_disponiveis_imp)
    
    atualizacao_onedrive_imp <- open_dataset(var_ambiente_import) %>% 
      select(co_ano, co_mes) %>% 
      distinct() %>% 
      collect() %>% 
      filter(max(co_ano) == co_ano) %>% 
      filter(max(co_mes) == co_mes) %>% 
      mutate(co_mes = str_pad(co_mes, 2, 'left', pad = '0')) %>% 
      unite(col = "atualizacao", co_ano, co_mes, sep = "-") %>% 
      pull(atualizacao)
    
    atualizacao_onedrive_exp <- open_dataset(var_ambiente_export) %>% 
      select(co_ano, co_mes) %>% 
      distinct() %>% 
      collect() %>% 
      filter(max(co_ano) == co_ano) %>% 
      filter(max(co_mes) == co_mes) %>% 
      mutate(co_mes = str_pad(co_mes, 2, 'left', pad = '0')) %>% 
      unite(col = "atualizacao", co_ano, co_mes, sep = "-") %>% 
      pull(atualizacao)
  }
}

# IMPORTANTE! O comex stat faz atualizacoes de dados apenas dentro do ano corrente. Por exemplo,
# o dado de janeiro do ano corrente pode ir mudando ao longo do ano, mas depois
# que o dado do ano fecha e passamos para o ano seguinte, não há mais atualizacoes
# do ano que recem passou. A ideia deste script eh que ele rode todo mes apos a
# atualizacao da base no comexstat. Dessa forma, depois desse script rodar pela
# primeira vez, ele criarah uma base de comercio do comex stat. Por seguranca,
# na atualizacao dos dados, este script sempre atualizara o dado do ano corrente e 
# o dado do ano imediatamente anterior. Isso evita que a base do ano imediatamente
# anterior fique desatualizada no caso do script eventualmente nao rodar por alguns
# meses na transicao de um ano para outro.


if(!primeira_execucao) {
  # primeiro deve-se testar se a base do onedrive se encontra atualizada com os dados
  # mais atualizados do comex stat. Caso a base do onedrive já esteja atualizada a 
  # funcao abaixo ira lancar um erro, interrompendo a execucao do script. O
  # resto do script so ira rodar se a base nao estiver atualizada.
  teste_base_export <- try(
    compara_base_onedrive(tipo = var_ambiente_export),
    silent = TRUE)
  
  teste_base_import <- try(
    compara_base_onedrive(tipo = var_ambiente_import),
    silent = TRUE)
  
  
  if(inherits(teste_base_export, "try-error") && inherits(teste_base_import, "try-error")) {
    # se a condição for verdadeira, a base está atualizada
    stop("Bases atualizadas")
  }
  
  # se a condição acima não for verdadeira, uma ou as duas bases não estão 
  # atualizadas. Dessa forma prosseguimos com atualização.
  
  # ano_update_base_oficial é o ano da última atulização dos dados no site do comex stat
  ano_update_base_oficial <- str_sub(get_last_update(), 1, 4)
  
  # ano_update_base_onedrive é o último ano de atualização da base do comex stat
  # no OneDrive
  ano_update_base_onedrive <- str_sub(atualizacao_onedrive_imp, 1, 4)
  
  # Além dos anos já definidos para exlcusão anteriormente, remover ano corrente
  # e ano imediatamente anterior da lista de exclusão
  excluir_anos_download <- 
    excluir_anos_download[!excluir_anos_download %in% ano_update_base_onedrive:ano_update_base_oficial]
  
  # Selecionar anos que serão atualizados/baixados nas base
  anos_para_baixar <- setdiff(serie_cstat_desejada, excluir_anos_download)
  
  # cria regex para selecão de links
  anos_para_baixar <- paste0(anos_para_baixar, collapse = "|")
}

# Baixar/atualizar dados --------------------------------------------------

# obter dados html de link_cs
page <- read_html(link_cs)

# obter links relevantes para download dos dados ano a ano
links_download <- page %>% 
  html_elements("table tr td a") %>% 
  html_attr("href") %>% 
  str_subset("/ncm/") %>% 
  str_subset("COMPLETA|CONFERENCIA", negate = TRUE) %>% 
  str_subset(anos_para_baixar)

# obter link de correlacao para paises
link_download_paises <- page %>% 
  html_elements("table tr td a") %>% 
  html_attr("href") %>% 
  str_subset("PAIS.csv")

# Define local do diretório temporário para download de arquivos
dir_temp_pais <- file.path(temp, "pais.csv")

# baixar correlação pais - caso download falhe, pode rodar manualmente
# as linhas de baixo para completar a organização da base.
download_pais <- tryCatch({
  download.file(
    url = link_download_paises,
    destfile = dir_temp_pais,
    mode = "wb"
  )
  if (!file.exists(dir_temp_pais) || file.info(dir_temp_pais)$size == 0) {
    stop("Download falhou ou arquivo vazio.")
  }
  TRUE
}, error = function(e) {
  message("Erro ao baixar o arquivo: ", e$message)
  FALSE
})

# abrir/trazer dados de pais para o R
paises <- fread(
  dir_temp_pais,
  encoding = "Latin-1"
) %>% 
  clean_names() %>% 
  as_tibble() %>% 
  select(co_pais, no_pais)


# aplicar função download_dados_cs_onedrive para vetor links_download
links_download %>%
  walk(~ download_dados_cs_onedrive(.x))

# apagar arquivos baixados
file.remove(file.path(temp, "temp.csv"))

# apaga arquivo de correlação de código e nome de país
# obs. o arquivo de correlação é apagado e baixado em toda atualização da base,
# pois eventualmente pode haver atualização da lista de países
file.remove(dir_temp_pais)