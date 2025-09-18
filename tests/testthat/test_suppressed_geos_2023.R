test_that("API is able to call all fields successfully", {
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "test-2023-suppressed-geo_resource.csv"),
    resource_lat_column = "IntPtLat",
    resource_lon_column = "IntPtLon",
    geo = "city",
    acs_data_year = "2023",
    resource_weight = ""
  )


  r <- get_api_response(param_list)

  counter <- 0
  sedt_status <- get_status(r$file_id)

  while(!(isTRUE(sedt_status$results$formdata$updates$finished)) & counter < 50){
    sedt_status <- get_status(r$file_id)
    counter = counter + 1
    Sys.sleep(3L)
  }

  expect_equal(sedt_status$results$formdata$updates$finished,
               TRUE)

  expect_equal(sedt_status$results$formdata$updates$acs_year, "2022")
}
)

