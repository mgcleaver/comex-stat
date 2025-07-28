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
