source("R/get_api_response_no_stop.R")
source("R/call_upload_user_files_no_stop.R")

test_that("year-misspecified", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "19", #ERROR HERE
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
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

  r <- get_api_response_no_stop(param_list)

  expect_identical(r[["status_code"]],
                   400L)

})
