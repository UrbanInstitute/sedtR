#Test if lat lon columns are in data
test_that("resource lat or lon column not in columns", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource_missinglatlon.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "geoid",
    demographic_columns = NA,
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "geoid",
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_identical(r[["status_code"]],
                   400L)

})
