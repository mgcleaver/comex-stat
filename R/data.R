#' Comex Stat's Country Table
#'
#' A table containing country codes and names
#'
#' @format A tibble with `r format(nrow(country_table), big.mark = ",")` rows and
#' `r format(ncol(country_table))` variables:
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
#' data(country_table)
#' head(country_table)
"country_table"

#' Comex Stat's State Table
#'
#' A table containing state abbreviations and full names.
#'
#' @format A tibble with `r format(nrow(state_table), big.mark = ",")` rows and
#' `r format(ncol(state_table))` variables::
#' \describe{
#'   \item{state}{State abbreviation (character)}
#'   \item{state_name}{Full state name (character)}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/UF.csv}
#'
#' @examples
#' data(state_table)
#' head(state_table)
"state_table"

#' Comex Stat's NCM Mapping Table
#'
#' A table containing ncm and other product category correlations.
#'
#' @format A tibble with `r format(nrow(ncm_table), big.mark = ",")` rows and
#' `r format(ncol(ncm_table))` variables:
#' \describe{
#'   \item{ncm}{NCM Product code}
#'   \item{unit_code}{Unit code for NCM}
#'   \item{cuci_basic_heading_code}{STIC basic heading code}
#'   \item{bec_n3_code)}{Broad economic category code}
#'   \item{co_siit}{SIIT code}
#'   \item{isic_class_code}{ISIC class code}
#'   \item{ncm_description}{Product description}
#'   \item{ncm_description_pt}{Product description portuguese}
#'   \item{ncm_description_es}{Product description spanish}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/NCM.csv}
#'
#' @examples
#' data(ncm_table)
#' head(ncm_table)
"ncm_table"

#' Comex Stat's International Standard Industrial Classification (ISIC) category
#' codes and descriptions table
#'
#' A table containing ISIC category codes and descriptions.
#'
#' @format A tibble with `r format(nrow(isic_table), big.mark = ",")` rows and
#' `r format(ncol(isic_table))` variables:
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
#' data(isic_table)
#' head(isic_table)
"isic_table"

#' Comex Stat's Broad Economic Category (BEC) codes and descriptions table
#'
#' A table containing BEC codes and descriptions.
#'
#' @format A tibble with `r format(nrow(bec_table), big.mark = ",")` rows and
#' `r format(ncol(bec_table))` variables:
#' \describe{
#'   \item{bec_n3_code}{BEC n3 code.}
#'   \item{bec_n3_desc_pt}{Description of BEC n3 in Portuguese.}
#'   \item{bec_n3_desc}{Description of BEC n3 in English.}
#'   \item{bec_n3_desc_es}{Description of BEC n3 in Spanish.}
#'   \item{bec_n2_code}{BEC n2 code.}
#'   \item{bec_n2_desc_pt}{Description of BEC n2 in Portuguese.}
#'   \item{bec_n2_desc}{Description of BEC n2 in English .}
#'   \item{bec_n2_desc_es}{Description of BEC n2 in Spanish.}
#'   \item{bec_n1_code}{BEC n1 code.}
#'   \item{bec_n1_desc_pt}{Description of BEC n1 in Portuguese.}
#'   \item{bec_n1_desc}{Description of BEC n1 in English.}
#'   \item{bec_n1_desc_es}{Description of BEC n1 in Spanish.}
#' }
#'
#' @source \url{https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_CGCE.csv}
#'
#' @examples
#' data(bec_table)
#' head(bec_table)
"bec_table"
