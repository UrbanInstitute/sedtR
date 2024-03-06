test_that("API and GUI results match for state", {
  param_list <- list(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "gui_example",
                                    "wa_mental_health_resource.csv"),
    resource_lat_column = "latitude",
    resource_lon_column = "longitude",
    geo = "state",
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
          filter_val = "WA",
          filter_type = "string",
          filter_column = "state",
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
                           "wa_mental_health_dem.csv"),
                      col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3))) %>%
    # gui includes geography and subgeography dem disparity scores. API only includes geography
    dplyr::filter(geo == "state")

  gui_geo <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                           "wa_mental_health_geo.csv"),
                      col_types = c("GEOID" = "character")) |>
    dplyr::select(-geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric), ~round(.x, digits = 3))) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("sig_diff"), as.character))



  gui_geo_cols <- names(gui_geo)

  api_dem <- dplyr::as_tibble(df_list$dd) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- dplyr::as_tibble(df_list$gd) |>
    # reorder cols to match gui
    dplyr::select(tidyselect::all_of(gui_geo_cols), -geometry) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3)))


  expect_true(all.equal(gui_dem , api_dem, tolerance = 0.001))

  expect_true(all.equal(gui_geo,
                        api_geo,
                        check.attributes = FALSE))

  ## same but 2022 ACS data ##

  param_list$acs_data_year <- "2022"

  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "wa_mental_health_dem_2022.csv"),
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3))) %>%
    # gui includes geography and subgeography dem disparity scores. API only includes geography
    dplyr::filter(geo == "state")

  gui_geo <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "wa_mental_health_geo_2022.csv"),
                             col_types = c("GEOID" = "character")) |>
    dplyr::select(-geometry) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric), ~round(.x, digits = 3))) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("sig_diff"), as.character))



  gui_geo_cols <- names(gui_geo)

  api_dem <- dplyr::as_tibble(df_list$dd) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- dplyr::as_tibble(df_list$gd) |>
    # reorder cols to match gui
    dplyr::select(tidyselect::all_of(gui_geo_cols), -geometry) |>
    dplyr::mutate(dplyr::across(.cols = where(is.numeric), ~round(.x, digits = 3)))


  expect_true(all.equal(gui_dem , api_dem, tolerance = 0.001))

  expect_true(all.equal(gui_geo,
                        api_geo,
                        check.attributes = FALSE))

}
)
