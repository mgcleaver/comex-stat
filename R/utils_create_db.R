
create_schema <- function(category = c("export", "import")) {
  category <- match.arg(category)

  if(category == "export") {
    # Schema for exports
    return(arrow::schema(
      co_ano = arrow::int32(),
      co_mes = arrow::int32(),
      co_ncm = arrow::utf8(),
      sg_uf_ncm = arrow::utf8(),
      co_pais = arrow::int32(),
      vl_fob = arrow::int64(),
      kg_liquido = arrow::int64(),
      qt_estat = arrow::int64()
    ))
  }

  if(category == "import") {
    # Schema for imports
    return(arrow::schema(
      co_ano = arrow::int32(),
      co_mes = arrow::int32(),
      co_ncm = arrow::utf8(),
      sg_uf_ncm = arrow::utf8(),
      co_pais = arrow::int32(),
      vl_fob = arrow::int64(),
      vl_cif = arrow::int64(), # exportações não tem esse dado
      kg_liquido = arrow::int64(),
      qt_estat = arrow::int64()
    ))
  }
}

compare_local_db <- function(file_dir) {
  temp_date_api <- get_last_update()
  temp_date_local <- most_recent_date(file_dir = file_dir)

  if (temp_date_api == temp_date_local) {
    return(TRUE)
  }
  return(FALSE)
}

get_last_update <- function() {
  url <- "https://api-comexstat.mdic.gov.br/general/dates/updated"

  response <- httr::GET(url)
  json_data <- suppressMessages(httr::content(response, as = "text"))

  last_update <- jsonlite::fromJSON(json_data, flatten = TRUE) |>
    purrr::pluck("data")

  paste0(last_update$year, "-", stringr::str_pad(last_update$monthNumber, 2, "left", "0"))
}


most_recent_date <- function(file_dir) {
  arrow::open_dataset(file_dir) |>
    dplyr::select(co_ano, co_mes) |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::filter(co_ano == max(co_ano)) |>
    dplyr::filter(co_mes == max(co_mes)) |>
    dplyr::mutate(co_mes = stringr::str_pad(co_mes, 2, side = "left", pad = "0")) |>
    dplyr::mutate(resultado = paste0(co_ano, "-", co_mes)) |>
    dplyr::pull(resultado)
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
    stop(glue::glue("Failed to download {category} {year_from_link} after 3 attempts.\n"))
  }
}

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
  category <- stringr::str_extract(link_download, "EXP|IMP") |>
    stringr::str_to_lower()

  message(glue::glue("Downloading {category} {year_from_link}\n"))
  download_cs_file(
    link_download = link_download,
    dir_file_download = temp_dir
  )

  if (category == "imp") {
    selected_data <- read_imports(temp_dir)
    write_cs_db(
      x = selected_data,
      path = stringr::str_subset(db_dirs, "imp"),
      data_schema = schemas[["imp"]]
    )
  } else if (category == "exp") {
    selected_data <- read_exports(temp_dir)
    write_cs_db(
      x = selected_data,
      path = stringr::str_subset(db_dirs, "exp"),
      data_schema = schemas[["exp"]]
    )
  }
  message(glue::glue("Download and data write for {category} {year_from_link} complete\n"))
}
