#' Add state name based on Comex Stat's state code
#'
#' @export
add_state_name <- function(
    x,
    drop_key = TRUE
) {

  utils::data("state_table", package = "comexstat", envir = environment())

  temp <- dplyr::left_join(
    x,
    dplyr::select(state_table, state, state_name),
    by = "state"
  )

  if (drop_key) {
    temp <- dplyr::select(temp, -state)
  }

  return(temp)

}
