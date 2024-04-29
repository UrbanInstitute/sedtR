test_that("Check that we successfully handle supplemental data without se columns", {
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/dc_test_api_demographic-missing_margins.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = NA,
      hispanic_men = NA
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic-missing_margins.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(
      hispanic_men = "hispanic_men_margin",
      male_under_18 = NA,
      female_under_18 = NA,
      children = "children_margin"
    ),
    resource_filters =NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  sedt_status <- get_status(r$file_id)
  counter <- 0

  while(!(isTRUE(sedt_status$results$formdata$updates$finished)) & counter < 50){
    sedt_status <- get_status(r$file_id)
    counter = counter + 1
    Sys.sleep(3L)
  }

  expect_equal(sedt_status$results$file_exists,
               TRUE)

  #Get output data:
  equity_data <- get_output_data(r$file_id)
  counter <- 0
  while(isFALSE(equity_data$file_exists) & counter < 50){
    Sys.sleep(3L)
    equity_data <- get_output_data(r$file_id)
  }

  demo_bias_data <- equity_data$demo_bias_data
  geo_bias_data <- equity_data$geo_bias_data

  #Check geo-bias data does not report anything as statistically significant for
  # columns with missing margins
  expect_false(
    any(
      as.logical(geo_bias_data$sig_diff_female_under_18_geographic)
      )
    )
  expect_false(
    any(as.logical(
      geo_bias_data$sig_diff_male_under_18_geographic
      )
    )
  )

  #Check demo-bias data does not report statistically significant results for
  # data with missing margins:
  expect_false(
    demo_bias_data |>
      dplyr::filter(census_var == "pct_hispanic_demographic") |>
      dplyr::pull(sig_diff)
  )

  expect_false(
    demo_bias_data |>
      dplyr::filter(census_var == "pct_hispanic_men_demographic") |>
      dplyr::pull(sig_diff)
  )
}
)

