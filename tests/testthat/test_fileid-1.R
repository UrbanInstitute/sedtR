test_that("fileid starts with 1", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019"
  )

  r <- get_api_response(param_list)
  expect_equal( str_sub(r$file_id, 1, 1), "1")
}
)

