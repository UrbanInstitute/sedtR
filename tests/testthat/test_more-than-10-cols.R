test_that("more than 10 cols", {

  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/demographic_wide.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns = list(nh_white_pop = "nh_white_pop_margin", hispanic = "hispanic_margin", hispanic_men = "hispanic_men_margin", c1 = NULL, c2 = NULL, c3 = NULL, c4 = NULL, c5 = NULL, c6 = NULL, c7 = NULL, c8 = NULL, c9 = NULL, c10 = NULL),
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code, r$error_message$error_message),
               c(400, "Columns cannot hold more than 10 items"))

})

# Testing geographic as well!

test_that("more than 10 cols", {

  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns = NA,
    geographic_file_path = here::here("tests/testthat/data/geographic_wide.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = "hispanic_men_margin", male_under_18 = "male_under_18_margin",
                            female_under_18 = "female_under_18_margin", children = "children_margin", c1 = NULL, c2 = NULL, c3 = NULL, c4 = NULL, c5 = NULL, c6 = NULL, c7 = NULL, c8 = NULL, c9 = NULL, c10 = NULL),
    resource_filters = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code, r$error_message$error_message),
               c(400, "Columns cannot hold more than 10 items"))

})
