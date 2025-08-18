#' Add CUCI (SITC) level descriptions based on Comex Stat's CUCI table (STIC table)
#'
#' @export
add_cuci_description <- function(
    x,
    level = c("basic_heading", "subgroup", "group", "division", "section", "all"),
    drop_key = TRUE
      ) {
  level <- match.arg(level)

  level_col <- dplyr::if_else(
    level == "all",
    "basic_heading|subgroup|group|division|section",
    level
  )

  regex_col_select <- paste0(
    "(?=.*",
    level_col,
    ")"
  )

  utils::data("ncm_table", package = "comexstat", envir = environment())
  cuci_table <- get("cuci_table", envir = asNamespace("comexstat"))

  temp <- dplyr::left_join(
    x,
    dplyr::select(ncm_table, ncm, cuci_basic_heading_code),
    by = "ncm"
  ) |>
    dplyr::left_join(
      dplyr::select(
        cuci_table,
        cuci_basic_heading_code,
        dplyr::matches(regex_col_select, perl = TRUE)),
      by = "cuci_basic_heading_code"
    )

  if (drop_key) {
    temp <- dplyr::select(temp, -cuci_basic_heading_code)
  }

  return(temp)
}
