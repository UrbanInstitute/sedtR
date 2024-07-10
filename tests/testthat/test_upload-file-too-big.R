source(here::here("tests", "testthat", "R", "create_big_data.R"))

#check if we need to recreate files:
exists_resource <- file.exists(here::here("tests", "testthat", "data", "dc_test_api_resource_big.csv"))
exists_demo <- file.exists(here::here("tests", "testthat", "data", "dc_test_api_demographic_big.csv"))
exists_geographic <-  file.exists(here::here("tests", "testthat", "data", "dc_test_api_geographic_big.csv"))

if (!all(exists_resource, exists_demo, exists_geographic)) {
  create_big_data()
}



test_that("upload file too big returns error", {

  #expect_equal(1, 1)

  ### resource to big:
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource_big.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns = NA,
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  testthat::expect_true(
    get_api_response(param_list)$status_code %in% c(413, 400)
  )


  ### demographic to big:
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic_big.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns = NA,
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  testthat::expect_true(
    get_api_response(param_list)$status_code %in% c(413, 400)
  )

  ### geographic to big:
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns = NA,
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic_big.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  testthat::expect_true(
    get_api_response(param_list)$status_code %in% c(413, 400)
  )

})

file.remove(here::here("tests", "testthat", "data", "dc_test_api_resource_big.csv"))
file.remove(here::here("tests", "testthat", "data", "dc_test_api_demographic_big.csv"))
file.remove(here::here("tests", "testthat", "data", "dc_test_api_geographic_big.csv"))
