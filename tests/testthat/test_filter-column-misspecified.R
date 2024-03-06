test_that("correctly specified filter works", {

  #non-existent column name;
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(list(filter_type = "number",
                                 filter_column = "name does not exist", #Error here
                                 filter_comparison = ">=",
                                 filter_val = 5)),
    resource_weight = NA
  )

  r <- get_api_response(param_list)
  expect_equal(c(r$status_code),
               c(400))

  #Provide string column with numeric filter_type:
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(list(filter_type = "number",
                                 filter_column = "Name", #Error- Name not a numeric column
                                 filter_comparison = ">=",
                                 filter_val = 5)),
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))

  #Provide numeric column with string "filter_type":
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(list(filter_type = "string",
                                 filter_column = "ObjectId", #ObjectIs is not string
                                 filter_comparison = ">=",
                                 filter_val = 5)),
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))

  #Provide string filter but with numeric filter_comparison:
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(list(filter_type = "string",
                                 filter_column = "Name",
                                 filter_comparison = ">=", #numeric operator for non-numeric col
                                 filter_val = 5)),
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))

  #Numeric filter but string filter_val
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(list(filter_type = "numeric",
                                 filter_column = "ObjectId",
                                 filter_comparison = ">=",
                                 filter_val = "5")), #string filter val,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))


  #String Filter but numeric val
  param_list <- list(
    resource_file_path = here::here("tests/testthat/data/dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = here::here("tests/testthat/data/dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NA,
                            male_under_18 = NA,
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(list(filter_type = "string",
                                 filter_column = "Name",
                                 filter_comparison = "==",
                                 filter_val = 5)), #Numeric filter
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  expect_equal(c(r$status_code),
               c(400))


})
