test_that("blank demographic geoid col", {

  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/dc_test_api_demographic.csv"),
    demographic_geo_id_column = NA, #ERROR IS ON THIS LINE!
    demographic_columns = list(nh_white_pop = "nh_white_pop_margin", hispanic = "hispanic_margin", hispanic_men = "hispanic_men_margin"),
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))

})
