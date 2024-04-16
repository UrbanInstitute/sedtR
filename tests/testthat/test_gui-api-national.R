test_that("API and GUI results match for national", {
  param_list <- list(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "gui_example",
                                    "us_library_outlets_resource.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUD",
    geo = "national",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = "HOURS"
  )


  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "us_library_outlets_dem.csv"),
                      col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3))) %>%
    # gui includes geography and subgeography dem disparity scores. API only includes geography
    dplyr::filter(geo == "national")

  gui_geo <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                           "us_library_outlets_geo.csv"),
                      col_types = c("GEOID" = "character")) |>
    dplyr::select(-geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric), ~round(.x, digits = 3))) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("sig_diff"), as.character))



  gui_geo_cols <- names(gui_geo)

  api_dem <- readr::read_csv(df_list$download_links$demographic_bias_csv,
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- readr::read_csv(df_list$download_links$geo_bias_csv,
                             col_types = c("GEOID" = "character")) |>
    # reorder cols to match gui
    dplyr::select(tidyselect::all_of(gui_geo_cols), -geometry) |>
    dplyr::mutate(dplyr::across(.cols = starts_with("sig_diff"), ~as.character(.x))) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3))) %>%
    dplyr::arrange(GEOID)


  expect_true(all.equal(gui_dem , api_dem, tolerance = 0.001))

  expect_true(all.equal(gui_geo,
                        api_geo,
                        tolerance = 0.001,
                        check.attributes = FALSE))

  ### same but 2022 ACS data ###

  param_list$acs_data_year <- "2022"

  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(stringr::str_glue("https://{s3_bucket}.s3.amazonaws.com/reference-data/demographic-bias/csv/us_library_outlets.csv"),
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3))) %>%
    # gui includes geography and subgeography dem disparity scores. API only includes geography
    dplyr::filter(geo == "national")

  gui_geo <- readr::read_csv(stringr::str_glue("https://{s3_bucket}.s3.amazonaws.com/reference-data/geo-bias/csv/us_library_outlets.csv"),
                             col_types = c("GEOID" = "character")) |>
    dplyr::select(-geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric), ~round(.x, digits = 3))) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("sig_diff"), as.character))



  gui_geo_cols <- names(gui_geo)

  api_dem <- readr::read_csv(df_list$download_links$demographic_bias_csv,
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- readr::read_csv(df_list$download_links$geo_bias_csv,
                             col_types = c("GEOID" = "character")) |>
    # reorder cols to match gui
    dplyr::select(tidyselect::all_of(gui_geo_cols), -geometry) |>
    dplyr::mutate(dplyr::across(.cols = starts_with("sig_diff"), ~as.character(.x))) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3))) %>%
    dplyr::arrange(GEOID)


  expect_true(all.equal(gui_dem , api_dem, tolerance = 0.001))

  expect_true(all.equal(gui_geo,
                        api_geo,
                        tolerance = 0.001,
                        check.attributes = FALSE))

}
)
