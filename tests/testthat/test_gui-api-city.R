test_that("API and GUI results match for city", {
  param_list <- list(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "gui_example",
                                    "minneapolis_bikes_resource.csv"),
    resource_lat_column = "lat",
    resource_lon_column = "lon",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = "capacity"
  )


  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(here::here("tests",
                                       "testthat",
                                       "data",
                                       "gui_example",
                                        "minneapolis_bikes_dem.csv"),
                             col_types = c("geo_fips" = "character")
                             ) |>
  dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                              ~round(.x, digits = 3)))

  gui_geo <- readr::read_csv(here::here("tests",
                                        "testthat",
                                        "data",
                                        "gui_example",
                                        "minneapolis_bikes_geo.csv"))

  api_dem <- readr::read_csv(df_list$download_links$demographic_bias_csv,
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                         ~round(.x, digits = 3)))

  api_geo <- readr::read_csv(df_list$download_links$geo_bias_csv)

  expect_true(all.equal(gui_dem |>  dplyr::select(-geo_mo),
                        api_dem |>  dplyr::select(-geo_mo))
              )

  expect_true(all.equal(gui_geo,
                        api_geo)
  )

  ##### Same but 2022 data ##########
  param_list$acs_data_year <- "2022"

  r <- get_api_response(param_list)

  df_list <- get_api_results(r$file_id)


  gui_dem <- readr::read_csv(str_glue("https://{s3_bucket}.s3.amazonaws.com/reference-data/demographic-bias/csv/minneapolis_bikes.csv"),
                             col_types = c("geo_fips" = "character")
  ) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  gui_geo <- readr::read_csv(str_glue("https://{s3_bucket}.s3.amazonaws.com/reference-data/geo-bias/csv/minneapolis_bikes.csv"))

  api_dem <- readr::read_csv(df_list$download_links$demographic_bias_csv,
                             col_types = c("geo_fips" = "character")) |>
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.numeric),
                                ~round(.x, digits = 3)))

  api_geo <- readr::read_csv(df_list$download_links$geo_bias_csv)

  expect_true(all.equal(gui_dem |>  dplyr::select(-geo_mo),
                        api_dem |>  dplyr::select(-geo_mo))
  )

  expect_true(all.equal(gui_geo,
                        api_geo)
  )

}
)
