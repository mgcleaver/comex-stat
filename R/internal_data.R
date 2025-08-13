#' Comex Stat's unit code and description table
#'
#' A table containing unit codes and descriptions
#'
#' @format A tibble with 15 rows and 4 columns:
#' \describe{
#'   \item{unit_code}{NCM unit code.}
#'   \item{unit_description_pt}{Unit description in Portuguese.}
#'   \item{sg_unid}{Unit abbreviation in Portuguese.}
#'   \item{unit_description}{Unit description in English.}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_UNIDADE.csv}
#' @keywords internal
#' @name unit_table
#' @docType data
NULL

#' Comex Stat's CUCI code and description table - only in portuguese
#'
#' A table containing unit codes and descriptions
#'
#' @format A tibble with 2971 rows and 6 columns:
#' \describe{
#'   \item{no_cuci_item}{CUCI item code}
#'   \item{no_cuci_item}{CUCI item description in Portuguese.}
#'   \item{no_cuci_sub}{CUCI subgroup description in Portuguese.}
#'   \item{no_cuci_grupo}{CUCI group description in Portuguese.}
#'   \item{no_cuci_divisao}{CUCI division description in Portuguese.}
#'   \item{no_cuci_sec}{CUCI section description in Portuguese.}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_CUCI.csv}
#' @keywords internal
#' @name cuci_table
#' @docType data
NULL
