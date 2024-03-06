#Test the logic that we drop value columns if there are more than 50% negative
# we should also drop associated margin columns. We drop margin columns if
# any values are negative.

test_that("Test negative columns are dropped", {
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/demographic_negative.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = here::here("tests/testthat/data/geographic_negative.csv"),
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
  while(!(isTRUE(sedt_status$results$formdata$updates$finished)) & counter < 50){
    sedt_status <- get_status(r$file_id)
    counter = counter + 1
    Sys.sleep(3L)
  }

  #Get output data:
  equity_data <- get_output_data(r$file_id)
  counter <- 0
  while(isFALSE(equity_data$file_exists) & counter < 50){
    Sys.sleep(3L)
    equity_data <- get_output_data(r$file_id)
  }

  demo_bias_data <- equity_data$demo_bias_data
  geo_bias_data <- equity_data$geo_bias_data


  #First check demographic data:
  # we want to see:
  #   hispanic_men warn
  #   all female_under_18 (value, margin, sig_dff) dropped
  #   male_under_18_margin dropped but value column stays in

  #Hispanic men (and all_female_under_18) warning:
  expect_true(
    all(
      c("hispanic_men_geographic", "female_under_18_geographic")
      %in%
        sedt_status$results$formdata$warnings$geographic_values_negative
    )
  )

  #All female_under_18 dropped
  expect_equal(
    sedt_status$results$formdata$warnings$geographic_dropped_over_half_values_negative,
    "female_under_18_geographic"
  )

  expect_false(
    any(
      c("prop_female_under_18_geographic,
        sig_diff_female_under_18_geographic,
        diff_female_under_18_geographic")
      %in%
        colnames(geo_bias_data)
      )
  )

  #male_under_18_margin dropped but value_column stays in:
  expect_false(
    any(
      geo_bias_data |>
        dplyr::pull(sig_diff_male_under_18_geographic) |>
        as.logical()
    )
  )

  expect_true(
    all(
      c("prop_male_under_18_geographic",
        "sig_diff_male_under_18_geographic",
        "diff_male_under_18_geographic")
      %in%
        colnames(geo_bias_data)
      )
  )



  #Second check geographic data:
  # we want to see:
  #   hispanic_men warn
  #   all hispanic (value, margin, sig_dff) dropped
  #   nh_white_pop_margin dropped but value column stays in

  #Warn about hispanic_men (and hispanic)"
  expect_true(
    all(
      c("hispanic_demographic",
        "hispanic_men_demographic")
      %in%
        sedt_status$results$form$warnings$demographic_values_negative
    )
  )

  #All hispanic dropped:
  expect_equal(
    sedt_status$results$formdata$warnings$demographic_dropped_over_half_values_negative,
    "hispanic_demographic"
  )

  expect_false(
      "hispanic_demographic" %in% demo_bias_data$census_var
  )

  #   nh_white_pop_margin dropped but value column stays in
  expect_equal(
    sedt_status$results$formdata$warnings$demographic_dropped_any_values_negative_margin,
    "nh_white_pop_demographic_margin"
  )

  expect_true(
    "nh_white_pop_demographic" %in% demo_bias_data$census_var
  )


  #Check it works
  expect_true(
    sedt_status$results$file_exists
  )
})

