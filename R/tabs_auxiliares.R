link_cs <-
  "https://www.gov.br/mdic/pt-br/assuntos/comercio-exterior/estatisticas/base-de-dados-bruta"

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
