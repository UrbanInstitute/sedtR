test_that("travel sheds for county perform as expected", {


  # TEST 1: Simple call works
  r <- call_sedt_api(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "polling_montgomery_county_md.csv"),
    resource_lat_column = "POINT_Y",
    resource_lon_column = "POINT_X",
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
    distance_time = 10
  )
  expect_equal(c(r$status_code),
               c(200))

  ## Test 2: call works with all options
  r <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2022",
    demographic_file_path = here::here("tests/testthat/data/demographic_negative.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = here::here("tests/testthat/data/geographic_negative.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(
      hispanic_men = "hispanic_men_margin",
      male_under_18 = "male_under_18_margin",
      female_under_18 = "female_under_18_margin",
      children = "children_margin"
    ),
    resource_filters = NA,
    resource_weight = "ObjectId",
    distance_mode = "drive",
    distance_time = 30

  )

  expect_equal(c(r$status_code),
               c(200))

  #Test 3: Call works at county scale and outside of DC:
  r <- call_sedt_api(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "polling_montgomery_county_md.csv"),
    resource_lat_column = "POINT_X",
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

  # Test 4: Call falls for non-2022 year
  # NOTE: HAVE NOT YET BUILT THIS INTO SEDT SO DON"T TEST YET

  #   call_upload_user_files(
  #     resource_file_path = here::here("tests",
  #                                   "testthat",
  #                                   "data",
  #                                   "polling_montgomery_county_md.csv"),
  #   resource_lat_column = "POINT_Y",
  #   resource_lon_column = "POINT_X",
  #   geo = "county",
  #   acs_data_year = "2021", #PROBLEM HERE
  #   demographic_file_path = NA,
  #   demographic_geo_id_column = NA,
  #   demographic_columns =  NA,
  #   geographic_file_path = NA,
  #   geographic_geo_id_column = NA,
  #   geographic_columns = NA,
  #   resource_filters = NA,
  #   resource_weight = NA,
  #   distance_mode = "walk",
  #   distance_time = 10
  # ) |>
  #  expect_error()




  # Test 5: Call fails for non-city or county data
  call_sedt_api(
    resource_file_path = here::here("tests",
                                    "testthat",
                                    "data",
                                    "polling_montgomery_county_md.csv"),
    resource_lat_column = "POINT_X",
    resource_lon_column = "POINT_Y",
    geo = "state", #PROBLEM HERE
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
    distance_time = 10
  ) |>
    expect_error()



  }
)
