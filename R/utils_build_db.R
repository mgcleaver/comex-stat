
read_imports <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1",
    select = c("CO_ANO", "CO_MES", "CO_NCM", "SG_UF_NCM", "CO_PAIS",
               "KG_LIQUIDO", "QT_ESTAT", "VL_FOB", "VL_FRETE", "VL_SEGURO")
  ) |>
    janitor::clean_names() |>
    dplyr::mutate(across(c(vl_fob, kg_liquido, qt_estat, vl_frete, vl_seguro), as.numeric)) |>
    dplyr::group_by(co_ano, co_mes, co_ncm, sg_uf_ncm, co_pais) |>
    dplyr::summarise(across(c(vl_fob, vl_seguro, vl_frete, kg_liquido, qt_estat), sum), .groups = "drop") |>
    dplyr::mutate(
      vl_cif = vl_fob + vl_seguro + vl_frete,
      co_ncm = stringr::str_pad(co_ncm, 8, "left", "0")
    ) |>
    dplyr::select(-vl_seguro, -vl_frete) |>
    dplyr::relocate(vl_cif, .after = vl_fob) |>
    dplyr::arrange(co_mes)
}


read_exports <- function(path) {
  data.table::fread(
    path,
    encoding = "Latin-1",
    select = c("CO_ANO", "CO_MES", "CO_NCM", "SG_UF_NCM",
               "CO_PAIS", "KG_LIQUIDO", "QT_ESTAT", "VL_FOB")
  ) |>
    janitor::clean_names() |>
    dplyr::mutate(across(c(vl_fob, kg_liquido, qt_estat), as.numeric)) |>
    dplyr::group_by(co_ano, co_mes, co_ncm, sg_uf_ncm, co_pais) |>
    dplyr::summarise(across(c(vl_fob, kg_liquido, qt_estat), sum), .groups = "drop") |>
    dplyr::mutate(co_ncm = stringr::str_pad(co_ncm, 8, "left", "0")) |>
    dplyr::arrange(co_mes)
}

write_cs_db <- function(x, path, data_schema) {
  df <- arrow::arrow_table(x)$cast(data_schema)
  arrow::write_dataset(df, path, partitioning = "co_ano")
}


build_db <- function(link_download, db_dirs, schemas) {
  temp_dir <- file.path(withr::local_tempdir(), "temp.csv")
  year_from_link <- stringr::str_extract(link_download, "[0-9]{4}")
  tipo <- stringr::str_extract(link_download, "EXP|IMP") |>
    stringr::str_to_lower()

  download_cs_file(
    link_download = link_download,
    dir_file_download = temp_dir
  )

  if (tipo == "imp") {
    selected_data <- read_imports(temp_dir)
    write_cs_db(
      x = selected_data,
      path = stringr::str_subset(db_dirs, "imp"),
      data_schema = schemas[["imp"]]
    )
  } else if (tipo == "exp") {
    selected_data <- read_exports(temp_dir)
    write_cs_db(
      x = selected_data,
      path = stringr::str_subset(db_dirs, "exp"),
      data_schema = schemas[["exp"]]
    )
  }
  message(glue::glue("Download and data write for {tipo} {year_from_link} complete\n"))
}

download_cs_file <- function(link_download, dir_file_download) {
  year_from_link <- stringr::str_extract(link_download, "[0-9]{4}")
  sleep <- 5
  download_success <- FALSE

  for (attempt in 1:3) {
    tryCatch({
      httr::GET(
        link_download,
        httr::write_disk(dir_file_download, overwrite = TRUE),
        httr::progress()
        )
      download_success <- TRUE
      break
    },
    error = function(e) {
      message(glue::glue("Attempt {attempt} failed: {e$message}"))
      if (attempt < 3) Sys.sleep(sleep)
    })
  }
  if (!download_success) {
    stop(glue::glue("Failed to download {tipo} {year_from_link} after 3 attempts.\n"))
  }
}

