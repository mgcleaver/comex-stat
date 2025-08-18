# Build internal data

brazilian_states <- c(
  "AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA",
  "MG", "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO",
  "RR", "RS", "SC", "SE", "SP", "TO"
)

# Get Comex Stat's unit table and build english descriptions
unit_table <- process_table("NCM_UNIDADE") |>
  dplyr::mutate(
    no_unid = stringr::str_to_sentence(no_unid),
    sg_unid = stringr::str_squish(sg_unid),
    unit_description = dplyr::case_when(
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
  ) |>
  dplyr::rename(unit_description_pt = no_unid) |>
  tibble::as_tibble()

# Get Comex Stat's CUCI (STIC) table - portuguese only
cuci_table <- process_table("NCM_CUCI") |>
  dplyr::select(
    cuci_basic_heading_code,
    cuci_basic_heading_desc_pt,
    cuci_subgroup_desc_pt,
    cuci_group_desc_pt,
    cuci_division_desc_pt,
    cuci_section_desc_pt
  ) |>
  tibble::as_tibble()

# Add to internal data
usethis::use_data(
  unit_table,
  cuci_table,
  brazilian_states,
  internal = TRUE,
  overwrite = TRUE)
