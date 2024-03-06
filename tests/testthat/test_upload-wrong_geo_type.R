source("R/get_api_response_no_stop.R")
source("R/call_upload_user_files_no_stop.R")

test_that("wrong geo parameters for resource, geographic, and demographic columns", {

  #Mis-specified "geo" input field for resource dataset:
  param_list <- list(
    resource_file_path =  here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "abc", #WRONG HERE!!!
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = NA,
    demographic_columns = NA,
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  testthat::expect_error(get_api_response(param_list))

  r <- get_api_response_no_stop(param_list)

  testthat::expect_identical(r[["status_code"]],
                             400L)

  #Mis-specified demographic_geo_id_column
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "idgeo", #Error here: column not in data
    demographic_columns =
      list(nh_white_po = "nh_white_pop_margin",
           hispan = "hispanic_margin",
           hispanic_me = "hispanic_men_margin"),
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  testthat::expect_identical(r[["status_code"]],
                             400L)

  #Mis-specified geographic_geo_id_column
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns = NA,
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "stfid", #ERROR here: not a real geoid
    geographic_columns =
      list(hispanic_men = "hispanic_men_margin",
           male_under_18 = "male_under_18_margin",
           female_under_18 = "female_under_18_margin",
           children = "children_margin"),
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  testthat::expect_identical(r[["status_code"]],
                             400L)
})
