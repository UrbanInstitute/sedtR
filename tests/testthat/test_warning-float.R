test_that("Warn about columns with population larger than tot_pop", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "demographic_float.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = "nh_white_pop_margin",
      hispanic = "hispanic_margin",
      hispanic_men = "hispanic_men_margin"
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "geographic_float.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(
      hispanic_men = "hispanic_men_margin",
      male_under_18 = "male_under_18_margin",
      female_under_18 = "female_under_18_margin",
      children = "children_margin"
    ),
    resource_filters = NA,
    resource_weight = NA
  )

  r <- get_api_response(param_list)

  #Set counter in case something goes wrong
  sedt_status <- get_status(r[["file_id"]])
  counter <- 0L
  while (!(isTRUE(sedt_status[["results"]][["formdata"]][["updates"]][["finished"]])) & counter < 50L) {
    sedt_status <- get_status(r[["file_id"]])
    counter <- counter + 1L
    Sys.sleep(1L)
  }


  testthat::expect_true(
    all(
      c("hispanic_men_geographic",
        "male_under_18_geographic_margin")
      %in%
        sedt_status[["results"]][["formdata"]][["warnings"]][["geographic_float_values"]]
    )
  )

  testthat::expect_true(
    all(
      c(
        "nh_white_pop_demographic_margin",
        "hispanic_demographic"
      ) %in%
        sedt_status[["results"]][["formdata"]][["warnings"]][["demographic_float_values"]]
    )
  )
})
