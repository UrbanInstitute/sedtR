test_that("incorrect geo column names", {

  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests/testthat/data/dc_test_api_demographic.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =
      list(nh_white_po = "nh_white_pop_margi",
           hispan = "hispanic_margi",
           hispanic_me = "hispanic_men_margi"), # Error: deleted last letter of each column
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

# Testing geographic as well
test_that("incorrect geo column names", {

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
    geographic_geo_id_column = "GEOID",
    geographic_columns =
      list(hispanic_men = "hispanic_men_margi",
           male_under_18 = "male_under_18_margi",
           female_under_18 = "female_under_18_margi",
           children = "children_margi"), # deleted final letter from margin cols
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))

})
