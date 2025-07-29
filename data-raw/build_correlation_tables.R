# load package functions and libraries

devtools::load_all()
library(dplyr)

# get state correlation table
state_corr <- process_corr_tables("UF")
state_corr <- state_corr |>
  select(state, state_name)
usethis::use_data(state_corr, internal = FALSE, overwrite = TRUE)

# get country correlation table
country_corr <- process_corr_tables("PAIS")
country_corr <- country_corr |>
  select(state, state_name)
usethis::use_data(country_corr, internal = FALSE, overwrite = TRUE)

# get ncm correlation table
ncm_corr <- process_corr_tables("NCM") %>%
  select(ncm, co_unid, co_cuci_item, co_cgce_n3, co_siit, co_isic_classe,
         ncm_description, ncm_description_pt, ncm_description_es) %>%
  distinct() %>%
  mutate(ncm = stringr::str_pad(ncm, 8, side = 'left', pad = '0'))
usethis::use_data(ncm_corr, internal = FALSE, overwrite = TRUE)

# get ncm cuci correlation table
cuci_corr <- process_corr_tables("NCM_CUCI")
usethis::use_data(cuci_corr, internal = FALSE, overwrite = TRUE)

# get ncm isic correlation table
isic_corr <- process_corr_tables("NCM_ISIC")

# get ncm cgce correlation table
cgce_corr <- process_corr_tables("NCM_CGCE")

# get unit correlation table
unit_corr <- process_corr_tables("NCM_UNIDADE")


