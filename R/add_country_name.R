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
