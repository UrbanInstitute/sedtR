test_that("different specifications for missing values handled correctly", {

  param_list <- list(
    resource_file_path = here::here("tests", "testthat", "data", "dc_test_api_resource.csv"),
    resource_lat_column = "Y",
    resource_lon_column = "X",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"),
    demographic_geo_id_column = "GEOID",
    demographic_columns =  list(
      nh_white_pop = NULL,
      hispanic = NA,
      hispanic_men = ""
    ),
    geographic_file_path = here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"),
    geographic_geo_id_column = "GEOID",
    geographic_columns = list(hispanic_men = NULL,
                            male_under_18 = "",
                            female_under_18 = NA,
                            children = NA),
    resource_filters = list(),
    resource_weight = NA
  )

  r <- get_api_response(param_list)
  counter <- 0L
  sedt_status <- get_status(r[["file_id"]])

  while (!(isTRUE(sedt_status[["results"]][["formdata"]][["updates"]][["finished"]])) & counter < 50L) {
    sedt_status <- get_status(r[["file_id"]])
    counter <- counter + 1L
    Sys.sleep(1L)
  }


  #Get output data:
  equity_data <- get_output_data(r[["file_id"]])
  counter <- 0L
  while (isFALSE(equity_data[["file_exists"]]) & counter < 50L) {
    Sys.sleep(1L)
    equity_data <- get_output_data(r[["file_id"]])
  }

  demo_bias_data <- equity_data[["demo_bias_data"]]
  geo_bias_data <- equity_data[["geo_bias_data"]]

  #Check we have no significant results for geo_bias_data
  any_true_geo <- geo_bias_data |>
    dplyr::mutate(
      across(contains("sig_diff"), as.logical),
      any_true = any(sig_diff_children_geographic,
                     sig_diff_female_under_18_geographic,
                     sig_diff_male_under_18_geographic,
                     sig_diff_hispanic_men_geographic)
    ) |>
    dplyr::pull(any_true) |>
    any()

  testthat::expect_false(any_true_geo)

  #Check we have no significant results for demo_bias_data
  all_false_demo <- demo_bias_data |>
    dplyr::filter(census_var %in% c("nh_white_pop_demographic",
                                    "hispanic_demographic",
                                    "hispanic_demographic")
    ) |>
    dplyr::pull(sig_diff) |>
    any()



  testthat::expect_identical(r[["status_code"]],
                             201L)
}
)
