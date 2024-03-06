test_that("API is able to call successfully for county", {
  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "miami_dade_county_fl_playgrounds.csv"),
    resource_lat_column = "LAT",
    resource_lon_column = "LON",
    geo = "county",
    acs_data_year = "2021",
    demographic_file_path = here::here("tests", "testthat", "data", "test_api_dem_county.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      male_under_5E = "male_under_5M",
        female_under_5E = "female_under_5M",
        masters_degreeE = "masters_degreeM",
        owner_occupiedE = "owner_occupiedM"
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "test_api_geo_county.csv"),
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

