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
      num_blackE = "num_blackM",
      num_whiteE = "num_whiteM",
      num_seniorsE = "num_seniorsM",
      num_childrenE = "num_childrenM",
      num_asianE = "num_asianM",
      num_hispE = "num_hispM"
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
  df_list <- get_api_results(r$file_id)

  geo_bias_data <- df_list$geo_bias_data
  demo_bias_data <- df_list$demo_bias_data

  #Get diff_data_city for specific portions:
  get_diff <- function(var) {
    val <- demo_bias_data |>
      dplyr::filter(census_var == var) |>
      dplyr::pull(diff_data_city)
    #print(val)
  }


  white_tool <- get_diff("pct_white")
  white_sup <- get_diff("pct_num_whiteE_demographic")

  black_tool <- get_diff("pct_black")
  black_sup <- get_diff("pct_num_blackE_demographic")

  asian_tool <- get_diff("pct_asian")
  asian_sup <- get_diff("pct_num_asianE_demographic")

  hisp_tool <- get_diff("pct_hisp")
  hisp_sup <- get_diff("pct_num_hispE_demographic")

  children_tool <- get_diff("pct_children")
  children_sup <- get_diff("pct_num_childrenE_demographic")

  seniors_tool <- get_diff("pct_seniors")
  seniors_sup <- get_diff("pct_num_seniorsE_demographic")

  testthat::expect_true(abs(white_tool - white_sup) < .0001)
  testthat::expect_true(abs(black_tool - black_sup) < .0001)
  testthat::expect_true(abs(asian_tool - asian_sup) < .0001)
  testthat::expect_true(abs(hisp_tool - hisp_sup) < .0001)
  testthat::expect_true(abs(children_tool - children_sup) < .0001)
  testthat::expect_true(abs(seniors_tool - seniors_sup) < .0005)



#
#   r <- get_api_response(param_list)
#
#   counter <- 0
#   sedt_status <- get_status(r$file_id)
#
#   while(!(isTRUE(sedt_status$results$formdata$updates$finished)) & counter < 50){
#     sedt_status <- get_status(r$file_id)
#     counter = counter + 1
#     Sys.sleep(3L)
#   }
#
#   expect_equal(sedt_status$results$formdata$updates$finished,
#                TRUE)
  }
 )

