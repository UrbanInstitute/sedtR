test_that("Ensure warning for missing columns", {
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "missing_demographic-pct_33.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "missing_geographic-pct_33.csv"),
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

  #Note: lambda function has the update_status_json which goes through and updates
  # values in the json iteratively, so we have to wait until the keys we are testing
  # have actually been added.
  while(
    !("geographic_cols_any_missing_values" %in% names(sedt_status$results$formdata$warnings)) &
    !("demographic_cols_any_missing_values" %in% names(sedt_status$results$formdata$warnings))
  ){
    sedt_status <- get_status(r$file_id)
    Sys.sleep(3L)
  }
  expect_true(
    all(
      "hispanic_men_geographic" %in% sedt_status$results$formdata$warnings$geographic_cols_any_missing_values,
      "male_under_18_geographic_margin" %in% sedt_status$results$formdata$warnings$geographic_cols_any_missing_values,
      "hispanic_demographic" %in% sedt_status$results$formdata$warnings$demographic_cols_any_missing_values,
      "nh_white_pop_demographic_margin" %in% sedt_status$results$formdata$warnings$demographic_cols_any_missing_values
      )
  )


  #Ensure they were not dropped
  expect_false(
    any(
      "geographic_dropped_cols_over_half_missing_values" %in%
        sedt_status$results$formdata$warnings,
      "demographic_dropped_cols_over_half_missing_values" %in%
                     sedt_status$results$formdata$warnings
      )
    )
  })

