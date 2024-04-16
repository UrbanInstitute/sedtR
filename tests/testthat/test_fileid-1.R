test_that("fileid starts with 1", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019"
  )

  r1 <- get_api_response(param_list)

  r2 <- get_api_response(param_list)

  r3 <- get_api_response(param_list)

  v <- c(str_sub(r1$file_id, 1, 1),
         str_sub(r2$file_id, 1, 1),
         str_sub(r3$file_id, 1, 1))

  expect_true(all(v == "1"))
}
)

