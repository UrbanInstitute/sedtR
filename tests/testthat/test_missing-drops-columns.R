test_that("Missing more than 50% of data in geographic and demographic columns", {
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/missing_demographic-pct_66.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = here::here("tests/testthat/data/missing_geographic-pct_66.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(
      hispanic_men = "hispanic_men_margin",
      male_under_18 = "male_under_18_margin",
      female_under_18 = "female_under_18_margin",
      children = "children_margin"
    ),
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  #Set counter in case something goes wrong
  sedt_status <- get_status(r$file_id)
  counter = 0
  while(
    !("geographic_dropped_cols_over_half_missing_values" %in% names(sedt_status$results$formdata$warnings)) &
    !("demographic_dropped_cols_over_half_missing_values" %in% names(sedt_status$results$formdata$warnings))
  ){
    sedt_status <- get_status(r$file_id)
    counter = counter + 1
    Sys.sleep(3L)
  }

  expect_true("hispanic_demographic" %in%
                sedt_status$results$formdata$warnings$demographic_dropped_cols_over_half_missing_values)
  expect_true("nh_white_pop_demographic_margin" %in%
                sedt_status$results$formdata$warnings$demographic_dropped_cols_over_half_missing_values)
  expect_true("hispanic_demographic_margin" %in%
                sedt_status$results$formdata$warnings$demographic_dropped_cols_over_half_missing_values)

  expect_true("male_under_18_geographic_margin" %in%
                sedt_status$results$formdata$warnings$geographic_dropped_cols_over_half_missing_values)
  expect_true("hispanic_men_geographic_margin" %in%
                sedt_status$results$formdata$warnings$geographic_dropped_cols_over_half_missing_values)
  expect_true("hispanic_men_geographic" %in%
                sedt_status$results$formdata$warnings$geographic_dropped_cols_over_half_missing_values)


  equity_data <- get_output_data(r$file_id)
  counter <- 0
  while(isFALSE(equity_data$file_exists) & counter < 50){
    Sys.sleep(3L)
    equity_data <- get_output_data(r$file_id)
  }

  demo_bias_data <- equity_data$demo_bias_data
  geo_bias_data <- equity_data$geo_bias_data

  #Check if the column we hope to drop from demographic data is actually dropped:

  hispanic_demographic_in_dem_bias <-
    "hispanic_demographic" %in% demo_bias_data$census_var

  no_sig_diff <- demo_bias_data |>
    dplyr::filter(census_var == "nh_white_pop_demographic") |>
    dplyr::pull(sig_diff) |>
    as.logical()

  expect_false(hispanic_demographic_in_dem_bias)

  #Currently fails: We need an update to equity_calculations
  expect_false(no_sig_diff)

  ###############################################
  #Check if the column we hope to drop from geographic data is actually dropped:

  sig_diffs_for_male_under_18 <- any(as.logical(geo_bias_data$sig_diff_male_under_18_geographic))

  hispanic_men_in_geo_bias <- "hispanic_men" %in% colnames(geo_bias_data)

  expect_false(any(sig_diffs_for_male_under_18, hispanic_men_in_geo_bias))
})
