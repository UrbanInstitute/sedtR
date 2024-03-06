test_that("blank geographic geoid col", {

  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns = NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = NA, #ERROR IS ON THIS LINE
    geographic_columns = list(hispanic_men = "hispanic_men_margin", male_under_18 = "male_under_18_margin",
                            female_under_18 = "female_under_18_margin", children = "children_margin"),
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))

})
