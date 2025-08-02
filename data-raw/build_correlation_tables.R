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
  select(ncm, co_unid, co_cuci_item, co_cgce_n3, co_siit, isic_class_code,
         ncm_description, ncm_description_pt, ncm_description_es) %>%
  distinct() %>%
  mutate(ncm = stringr::str_pad(ncm, 8, side = 'left', pad = '0'))
usethis::use_data(ncm_corr, internal = FALSE, overwrite = TRUE)

# get ncm isic correlation table
isic_corr <- process_corr_tables("NCM_ISIC")
usethis::use_data(isic_corr, internal = FALSE, overwrite = TRUE)

# get Comex Stat's broad economic category table
bec_corr <- process_corr_tables("NCM_CGCE")
usethis::use_data(cuci_corr, internal = FALSE, overwrite = TRUE)

# get unit correlation table
unit_corr <- process_corr_tables("NCM_UNIDADE")
usethis::use_data(cuci_corr, internal = FALSE, overwrite = TRUE)

# get ncm cuci correlation table
cuci_corr <- process_corr_tables("NCM_CUCI") %>%
  select(
    co_cuci_item, no_cuci_item, no_cuci_sub, no_cuci_grupo,
    no_cuci_divisao, no_cuci_sec
  )
usethis::use_data(cuci_corr, internal = TRUE, overwrite = TRUE)

