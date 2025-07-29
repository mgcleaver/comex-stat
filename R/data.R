#' Country Correlation Table
#'
#' A dataset containing correlations between selected variables.
#'
#' @format A tibble with 281 rows and 6 variables:
#' \describe{
#'   \item{country_code}{Brazilian country code (character)}
#'   \item{country_code_ison3}{ISON3 country code (character)}
#'   \item{country_code_isoa3}{ISOA3 country code (character)}
#'   \item{country_name_pt)}{Country name portuguese (character)}
#'   \item{country_name}{Country name (character)}
#'   \item{country_name_es}{Country name spanish (character)}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/PAIS.csv}
#'
#' @examples
#' data(country_corr)
#' head(country_corr)
"country_corr"

#' State Correlation Table
#'
#' A dataset containing correlations between selected variables.
#'
#' @format A tibble with 34 rows and 2 variables:
#' \describe{
#'   \item{state}{State abbreviation (character)}
#'   \item{state_name}{Full state name (character)}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/UF.csv}
#'
#' @examples
#' data(state_corr)
#' head(state_corr)
"state_corr"

#' NCM Correlation Table
#'
#' A dataset containing correlations between selected variables.
#'
#' @format A tibble with 13,722 rows and 9 variables:
#' \describe{
#'   \item{ncm}{Product code (character)}
#'   \item{co_unid}{Unit code (integer)}
#'   \item{co_cuci}{CUCI code (character)}
#'   \item{co_cgce_n3)}{CGCE code (integer)}
#'   \item{co_siit}{SIIT code (integer)}
#'   \item{co_isic_classe}{isic code (integer)}
#'   \item{ncm_description}{Product description (integer)}
#'   \item{ncm_description_pt}{Product description portuguese (integer)}
#'   \item{ncm_description_es}{Product description spanish (integer)}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/NCM.csv}
#'
#' @examples
#' data(ncm_corr)
#' head(ncm_corr)
"ncm_corr"
