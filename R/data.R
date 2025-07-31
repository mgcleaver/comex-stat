#' Country Correlation Table
#'
#' A table containing country codes and names
#'
#' @format A tibble with `r format(nrow(country_corr), big.mark = ",")` rows and
#' `r format(ncol(country_corr))` variables:
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
#' A table containing state abbreviations and full names.
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
#' A table containing ncm and other product category correlations.
#'
#' @format A tibble with 13,722 rows and 9 variables:
#' \describe{
#'   \item{ncm}{Product code (character)}
#'   \item{co_unid}{Unit code (integer)}
#'   \item{co_cuci}{CUCI code (character)}
#'   \item{co_cgce_n3)}{CGCE code (integer)}
#'   \item{co_siit}{SIIT code (integer)}
#'   \item{isic_class_code}{ISIC class code (integer)}
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

#' ISIC category codes and descriptions
#'
#' A table containing ISIC category codes and descriptions.
#'
#' @format A tibble with `r format(nrow(isic_corr), big.mark = ",")` rows and
#' `r format(ncol(isic_corr))` variables:
#' \describe{
#'   \item{isic_class_code}{ISIC class code.}
#'   \item{isic_class_desc_pt}{Description of ISIC class in Portuguese.}
#'   \item{isic_class_desc}{Description of ISIC class in English.}
#'   \item{isic_class_desc_es}{Description of ISIC class in Spanish.}
#'   \item{isic_group_code}{Code of the ISIC group.}
#'   \item{isic_group_desc_pt}{Description of ISIC group in Portuguese.}
#'   \item{isic_group_desc}{Description of ISIC group in English .}
#'   \item{isic_group_desc_es}{Description of ISIC group in Spanish.}
#'   \item{isic_division_code}{ISIC division code.}
#'   \item{isic_division_desc_pt}{Description of ISIC division in Portuguese.}
#'   \item{isic_division_desc}{Description of ISIC division in English.}
#'   \item{isic_division_desc_es}{Description of ISIC division in Spanish.}
#'   \item{isic_section_code}{ISIC section code.}
#'   \item{isic_section_desc_pt}{Description of ISIC section in Portuguese.}
#'   \item{isic_section_desc}{Description of ISIC section in English.}
#'   \item{isic_section_desc_es}{Description of ISIC section in Spanish.}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_ISIC.csv}
#'
#' @examples
#' data(isic_corr)
#' head(isic_corr)
"isic_corr"
