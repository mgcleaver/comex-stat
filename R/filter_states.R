#' Wrapper to Filter Brazilian States
#'
#' A wrapper around [dplyr::filter()] to retain only rows with
#'  Brazilian state abbreviations. The column state also has non-state data.
#'  So this wrapper filter only state data.
#'
#' @param x A data frame that must include a column named `state`.
#'
#' @return A filtered data frame containing only rows with valid Brazilian
#'  states in the `state` column.
#'
#' @details
#' The `state` column must exist in the input data frame. If missing,
#' the function throws an error. The internal list of valid states is defined
#' in the object `brazilian_states`, assumed to be loaded with the package.
#'
#' @examples
#' df <- data.frame(state = c("SP", "RJ", "ND"), value = 1:3)
#' filter_states(df)
#'
#' @export
filter_states <- function(x) {
  if (!"state" %in% names(x)) {
    stop("The 'state' column does not exist.")
  }
  dplyr::filter(x, state %in% brazilian_states)
}
