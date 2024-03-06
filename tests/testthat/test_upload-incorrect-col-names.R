test_that("incorrectly specifying col names gives error", {

  # test with incorrect geographic_geo_id_column, should be "geoid"
  param_list <- list(
    resource_file_path =  here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path =  here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "wrong_col",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  testthat::expect_identical(c(r[["status_code"]], r[["error_message"]]),
                             c(400L,
                               "wrong_col is expected in ['GEOID', 'NAME', 'hispanic_men', 'male_under_18', 'female_under_18', 'hispanic_men_margin', 'male_under_18_margin', 'female_under_18_margin', 'children', 'children_margin']"))

  # specifying incorrect column name in geographic_columns
  #Note that the dc_test_api_geographic.csv file does not have a hispanic_women column in it
  param_list[["geographic_geo_id_column"]] <- "GEOID"
  param_list[["geographic_columns"]]  <- list(hispanic_women = NA,
                                            male_under_18 = NA,
                                            female_under_18 = NA,
                                            children = NA)

  r <- get_api_response(param_list)

  testthat::expect_identical(c(r[["status_code"]], r[["error_message"]]),
                             c(400L,
                               "hispanic_women is expected to be in ['GEOID', 'NAME', 'hispanic_men', 'male_under_18', 'female_under_18', 'hispanic_men_margin', 'male_under_18_margin', 'female_under_18_margin', 'children', 'children_margin']"))


})
