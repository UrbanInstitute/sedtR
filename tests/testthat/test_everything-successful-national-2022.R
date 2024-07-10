test_that("API is able to call successfully for national", {
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "us_library_outlets.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUD",
    geo = "national",
    acs_data_year = "2022",
    demographic_file_path = here::here("tests", "testthat", "data", "test_api_dem_national.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      num_blackE = "num_blackM",
      num_whiteE = "num_whiteM",
      num_seniorsE = "num_seniorsM",
      num_childrenE = "num_childrenM",
      num_asianE = "num_asianM",
      num_hispE = "num_hispM"
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "test_api_geo_national.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns =  list(
      male_under_5E = "male_under_5M",
      female_under_5E = "female_under_5M",
      masters_degreeE = "masters_degreeM",
      owner_occupiedE = "owner_occupiedM"
    )
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
  }
 )

# why are supplemental geographic cols all getting dropped
# need to pass precalculated dem disparity into fxn

