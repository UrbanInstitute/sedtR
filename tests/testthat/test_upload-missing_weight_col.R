test_that("resource weight not in columns", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource-filter_and_weight.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns = NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA, # [{"filter_type": "string", "filter_column": "Public_Display", "filter_comparison": "==", "filter_val": "Yes"}]
    resource_weight = "bogus"
  )

  r <- get_api_response(param_list)

  expect_identical(r[["status_code"]],
                   400L)

})
