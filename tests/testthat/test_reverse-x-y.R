test_that("lambda switches lat and lon when cols reversed", {
  r <- call_sedt_api(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "polling_montgomery_county_md.csv"),
    resource_lat_column = "POINT_X", # reversed lat and lon cols
    resource_lon_column = "POINT_Y",
    geo = "county",
    acs_data_year = "2022",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA,
    distance_mode = "walk",
    distance_time = 20
  )
  expect_equal(c(r$status_code),
               c(200))

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "X", # reversed lat and lon cols
    resource_lon_column = "Y",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "test_api_dem_city.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      num_blackE = "num_blackM",
      num_whiteE = "num_whiteM",
      num_seniorsE = "num_seniorsM",
      num_childrenE = "num_childrenM",
      num_asianE = "num_asianM",
      num_hispE = "num_hispM"
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(
      hispanic_men = "hispanic_men_margin",
      male_under_18 = "male_under_18_margin",
      female_under_18 = "female_under_18_margin",
      children = "children_margin"
    ),
    resource_filters =
      list(
        list(
          filter_val = "Yes",
          filter_type = "string",
          filter_column = "Public_Display",
          filter_comparison = "=="
        ),
        list(
          filter_val = 5,
          filter_type = "number",
          filter_column = "ObjectId",
          filter_comparison = ">"
        )
      ),
    resource_weight = "ObjectId"
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

