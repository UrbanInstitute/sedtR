test_that("Test non-numeric geographic not accepted", {
  # test with non-numeric geographic columns
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns = NA,
    geographic_file_path = here::here("tests/testthat/data/geographic_non_numeric.csv"),
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

  sedt_status <- get_status(r$file_id)
  counter = 0

  while(!("geographic_cols_cannot_be_converted_numeric" %in% names(sedt_status$results$formdata$`error-messages`))
        &
        counter < 50
        ){
    sedt_status <- get_status(r$file_id)
    counter = counter + 1
    Sys.sleep(3L)
  }

  expect_true(sedt_status$results$formdata$`error-messages`$geographic_cols_cannot_be_converted_numeric)

  ###############
  #Same test but for demographic geographics:
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/demographic_non_numeric.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  sedt_status <- get_status(r$file_id)
  counter = 0

  while(!("demographic_cols_cannot_be_converted_numeric" %in% names(sedt_status$results$formdata$`error-messages`))
        &
        counter < 50
  ){
    sedt_status <- get_status(r$file_id)
    counter = counter + 1
    Sys.sleep(3L)
  }

  expect_true(sedt_status$results$formdata$`error-messages`$demographic_cols_cannot_be_converted_numeric)

  })
