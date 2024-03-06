test_that("API and GUI results match for county", {

  param_list <- list(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "gui_example",
                                    "miami_dade_county_fl_playgrounds_resource.csv"),
    resource_lat_column = "LAT",
    resource_lon_column = "LON",
    geo = "county",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters =
      list(
        list(
          filter_val = "Yes",
          filter_type = "string",
          filter_column = "TOTLOT",
          filter_comparison = "=="
        )
      ),
    resource_weight = NA
  )


  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "miami_dade_county_fl_playgrounds_dem.csv"),
                      col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  gui_geo <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "miami_dade_county_fl_playgrounds_geo.csv"
                                        ),
                      col_types = c("GEOID" = "character")) |>
    dplyr::select(-geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3))) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("sig_diff"),
                                as.character))

  gui_geo_cols <- names(gui_geo)

  api_dem <- dplyr::as_tibble(df_list$dd) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- dplyr::as_tibble(df_list$gd) |>
    # reorder cols to match gui
    dplyr::select(dplyr::all_of(gui_geo_cols), -geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))


  expect_true(all.equal(gui_dem , api_dem, tolerance = 0.001))

  expect_true(all.equal(gui_geo,
                        api_geo,
                        tolerance = 0.01,
                        check.attributes = FALSE))

  ### same but 2022 ACS data ###

  param_list$acs_data_year <- "2022"
  print(param_list$acs_data_year)

  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "miami_dade_county_fl_playgrounds_dem_2022.csv"),
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  gui_geo <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "miami_dade_county_fl_playgrounds_geo_2022.csv"
  ),
  col_types = c("GEOID" = "character")) |>
    dplyr::select(-geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3))) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("sig_diff"),
                                as.character))

  gui_geo_cols <- names(gui_geo)

  api_dem <- dplyr::as_tibble(df_list$dd) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- dplyr::as_tibble(df_list$gd) |>
    # reorder cols to match gui
    dplyr::select(dplyr::all_of(gui_geo_cols), -geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))


  expect_true(all.equal(gui_dem , api_dem, tolerance = 0.001))

  expect_true(all.equal(gui_geo,
                        api_geo,
                        tolerance = 0.01,
                        check.attributes = FALSE))

})
