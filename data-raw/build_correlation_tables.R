# load package functions and libraries

devtools::load_all()
library(dplyr)

# Get Comex Stat's state table
state_table <- process_table("UF")
state_table <- state_table |>
  select(state, state_name)
usethis::use_data(state_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's country table
country_table <- process_table("PAIS")
usethis::use_data(country_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's NCM mapping table
ncm_table <- process_table("NCM") |>
  select(ncm, unit_code, co_cuci_item, bec_n3_code, co_siit, isic_class_code,
         ncm_description, ncm_description_pt, ncm_description_es) |>
  distinct() |>
  mutate(ncm = stringr::str_pad(ncm, 8, side = 'left', pad = '0'))
usethis::use_data(ncm_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's international standard industrial classification table
isic_table <- process_table("NCM_ISIC")
usethis::use_data(isic_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's broad economic category table
bec_table <- process_table("NCM_CGCE")
usethis::use_data(bec_table, internal = FALSE, overwrite = TRUE)

# Get Comex Stat's unit table and build english descriptions
unit_table <- process_table("NCM_UNIDADE") |>
  mutate(
    no_unid = stringr::str_to_sentence(no_unid),
    sg_unid = stringr::str_squish(sg_unid),
    unit_description = case_when(
      no_unid == "Quilograma liquido" ~ "Net kilogram",
      no_unid == "Numero (unidade)" ~ "Number (unit)",
      no_unid == "Milheiro" ~ "Thousand units",
      no_unid == "Pares" ~ "Pairs",
      no_unid == "Metro" ~ "Meter",
      no_unid == "Metro quadrado" ~ "Square meter",
      no_unid == "Metro cubico" ~ "Cubic meter",
      no_unid == "Litro" ~ "Liter",
      no_unid == "Mil quilowatt hora" ~ "Thousand kilowatt hour",
      no_unid == "Quilate" ~ "Carat",
      no_unid == "Duzia" ~ "Dozen",
      no_unid == "Tonelada metrica liquida" ~ "Net metric ton",
      no_unid == "Grama liquido" ~ "Net gram",
      no_unid == "Bilhoes de unidades internacionais" ~ "Billion international units",
      no_unid == "Quilograma bruto" ~ "Gross kilogram",
      TRUE ~ NA_character_)
  )
usethis::use_data(unit_table, internal = TRUE, overwrite = TRUE)

# Get Comex Stat's CUCI table - portuguese only
cuci_table <- process_table("NCM_CUCI") |>
  select(
    co_cuci_item, no_cuci_item, no_cuci_sub, no_cuci_grupo,
    no_cuci_divisao, no_cuci_sec
  )
usethis::use_data(cuci_table, internal = TRUE, overwrite = TRUE)

