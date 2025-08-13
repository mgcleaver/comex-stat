# load package functions and libraries

devtools::load_all()

# Get Comex Stat's state table
state_table <- process_table("UF")
state_table <- state_table |>
  dplyr::select(state, state_name) |>
  tibble::as_tibble()
usethis::use_data(state_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's country table
country_table <- process_table("PAIS") |>
  tibble::as_tibble()
usethis::use_data(country_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's NCM mapping table
ncm_table <- process_table("NCM") |>
  dplyr::select(ncm, unit_code, co_cuci_item, bec_n3_code, co_siit, isic_class_code,
         ncm_description, ncm_description_pt, ncm_description_es) |>
  dplyr::distinct() |>
  dplyr::mutate(ncm = stringr::str_pad(ncm, 8, side = 'left', pad = '0')) |>
  tibble::as_tibble()
usethis::use_data(ncm_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's international standard industrial classification table
isic_table <- process_table("NCM_ISIC") |>
  tibble::as_tibble()
usethis::use_data(isic_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's broad economic category table
bec_table <- process_table("NCM_CGCE") |>
  tibble::as_tibble()
usethis::use_data(bec_table, internal = FALSE, overwrite = TRUE)
