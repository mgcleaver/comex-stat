filter_states <- function(x) {
  if (!"state" %in% names(x)) {
    stop("The 'state' column does not exist.")
  }
  dplyr::filter(x, state %in% brazilian_states)
}
