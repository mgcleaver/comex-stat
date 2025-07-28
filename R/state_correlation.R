#' State Correlation Table
#'
#' A dataset containing correlations between selected variables.
#'
#' @format A tibble with 34 rows and 3 variables:
#' \describe{
#'   \item{state_code}{State code (integer)}
#'   \item{state}{State abbreviation (character)}
#'   \item{state_name}{Full state name (character)}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/UF.csv}
#'
#' @examples
#' data(state_correlation)
#' head(state_correlation)
"state_correlation"
