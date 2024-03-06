test_that("incorrect file type", {

  #geographic is excel:
  param_list <- list(
    resource_file_path =  here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path =  here::here("tests", "testthat", "data", "dc_test_api_geographic.xlsx"),
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

  testthat::expect_identical(r[["status_code"]],
                             400L)

  testthat::expect_identical(r[["error_message"]],
                             "Only CSV and TSV files are allowed!")


  #demographic is excel:
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.xlsx"),
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

  r <- get_api_response(param_list)

  testthat::expect_identical(r[["status_code"]],
                             400L)

  testthat::expect_identical(r[["error_message"]],
                             "Only CSV and TSV files are allowed!")

  #resource is excel
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.xlsx"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
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

  r <- get_api_response(param_list)

  testthat::expect_identical(r[["status_code"]],
                             400L)

  testthat::expect_identical(r[["error_message"]],
                             "Only CSV and TSV files are allowed!")


})
