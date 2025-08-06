#' Add Country Name Based on Comex Stat's Country Code
#'
#' A convenience wrapper that joins a country name to the Comex Stat database
#' based on the `country_code` column.
#'
#' This function performs a left join between the input data frame and an
#' external reference table `country_table`,
#' adding a country name column in the desired language (`en`, `pt`, or `es`).
#'
#' @param x A data frame that must contain a `country_code` column with
#' valid country codes.
#' @param lang A string indicating the desired language for the country name.
#'   Must be one of `"en"` (English), `"pt"` (Portuguese), or `"es"` (Spanish).
#'   Defaults to `"en"`.
#' @param drop_key Logical. If `TRUE` (default), the `country_code` column is
#' dropped after the join.
#'
#' @return A data frame with a new column for the country name in the selected
#' language.
#'
#' @details
#' The function uses a package reference table called `country_table`
#' that must contain the columns:
#' `country_code`, `country_name`, `country_name_pt`, and `country_name_es`.
#' It uses [dplyr::left_join()] and [dplyr::select()] internally.
#'
#' If the column `country_code` is missing from the input data frame, the function will raise an error during the join.
#'
#' @examples
#' df <- data.frame(country_code = c(20, 23, 40))
#' add_country_name(df, lang = "pt")
#'
#' @export
add_country_name <- function(
    x,
    lang = c("en","pt", "es"),
    drop_key = TRUE
) {
  lang <- match.arg(lang)

  name_col <- switch(
    lang,
    en = "country_name",
    pt = "country_name_pt",
    es = "country_name_es"
  )

  temp <- dplyr::left_join(
    x,
    dplyr::select(country_table, country_code, dplyr::all_of(name_col)),
    by = "country_code"
  )

  if (drop_key) {
    temp <- dplyr::select(temp, -country_code)
  }

  return(temp)

}
