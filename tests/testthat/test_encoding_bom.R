# Houston Test - Used Animal Service Requests 2016 from open data portal
# https://data.houstontx.gov/dataset/barc-animal-service-requests/resource/085943d4-fe3b-4a9e-b3a0-c7da3aae9b4e

test_that("Test BOM Houston Example", {

  r <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/houston_test.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUDE",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r$status_code, 200)

  # Add BOM
  data <- readr::read_csv(here::here("tests/testthat/data/houston_test.csv"))
  readr::write_excel_csv(data, here::here("tests/testthat/data/houston_test_bom.csv"))
  test <- read.csv(here::here("tests/testthat/data/houston_test_bom.csv"))

  r2 <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/houston_test_bom.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUDE",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  )

  expect_equal(r2$stat, 200)
  }
)

test_that("Test BOM Dallas Example", {

  # Dallas data
  # https://www.dallasopendata.com/Services/Dallas-Cultural-Centers/6cte-99qc/about_data

  r <- call_sedt_api(
        resource_file_path = here::here("tests/testthat/data/dallas_test.csv"),
        resource_lat_column = "Latitude",
        resource_lon_column = "Longitude",
        geo = "city",
        acs_data_year = "2019",
        demographic_file_path = NA,
        demographic_geo_id_column = NA,
        demographic_columns =  NA,
        geographic_file_path = NA,
        geographic_geo_id_column = NA,
        geographic_columns = NA,
        resource_filters = NA,
        resource_weight = NA
      ) # Successful call

  expect_equal(r$status_code, 200)

# Add BOM
  data <- readr::read_csv(here::here("tests/testthat/data/dallas_test.csv"))
  readr::write_excel_csv(data, here::here("tests/testthat/data/dallas_test_bom.csv"))
  test <- read.csv(here::here("tests/testthat/data/dallas_test_bom.csv")) #no visible changes to column names as a prefix?

  r2 <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/dallas_test_bom.csv"),
    resource_lat_column = "Latitude",
    resource_lon_column = "Longitude",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
    ) # Successful call

  expect_equal(r2$status_code, 200)

  }
)



test_that("Test BOM Ft. Worth Example", {

  # Fort Worth Data - 2024 traffic accidents
  # https://data.fortworthtexas.gov/Public-Safety/Current-Traffic-Accidents/eax3-qev8/about_data

  r <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/ftworth_test.csv"),
    resource_lat_column = "Latitude",
    resource_lon_column = "Longitude",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r$status_code, 200)

  # Add BOM
  data <- readr::read_csv(here::here("tests/testthat/data/ftworth_test.csv"))
  readr::write_excel_csv(data, here::here("tests/testthat/data/ftworth_test_bom.csv"))
  test <- read.csv(here::here("tests/testthat/data/ftworth_test_bom.csv"))

  r2 <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/ftworth_test_bom.csv"),
    resource_lat_column = "Latitude",
    resource_lon_column = "Longitude",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r2$status_code, 200)
}
)



test_that("Test BOM Austin Example", {

# Austin Data - Code Complaint Cases
# https://data.austintexas.gov/Public-Safety/Austin-Code-Complaint-Cases/6wtj-zbtb/about_data

  r <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/austin_test.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUDE",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r$status_code, 200)

  # Add BOM
  data <- readr::read_csv(here::here("tests/testthat/data/austin_test.csv"))
  readr::write_excel_csv(data, here::here("tests/testthat/data/austin_test_bom.csv"))
  test <- read.csv(here::here("tests/testthat/data/austin_test_bom.csv"))

  r2 <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/austin_test_bom.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUDE",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r2$status_code, 200)
}
)



test_that("Test BOM Chicago Example", {

  # Chicago - Affordable Housing Developments
  # https://data.cityofchicago.org/Community-Economic-Development/Affordable-Rental-Housing-Developments/s6ha-ppgi/about_data


  r <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/chicago_test.csv"),
    resource_lat_column = "Latitude",
    resource_lon_column = "Longitude",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  # Add BOM
  data <- readr::read_csv(here::here("tests/testthat/data/chicago_test.csv"))
  readr::write_excel_csv(data, here::here("tests/testthat/data/chicago_test_bom.csv"))
  test <- read.csv(here::here("tests/testthat/data/chicago_test_bom.csv"))

  r2 <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/chicago_test_bom.csv"),
    resource_lat_column = "Latitude",
    resource_lon_column = "Longitude",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r2$status_code, 200)
}
)

test_that("LA encoding example",{

  r <- call_sedt_api(
    resource_file_path = here::here("tests/testthat/data/test_la_encoding.csv"),
    resource_lat_column = "LATITUDE",
    resource_lon_column = "LONGITUDE",
    geo = "city",
    acs_data_year = "2019",
    demographic_file_path = NA,
    demographic_geo_id_column = NA,
    demographic_columns =  NA,
    geographic_file_path = NA,
    geographic_geo_id_column = NA,
    geographic_columns = NA,
    resource_filters = NA,
    resource_weight = NA
  ) # Successful call

  expect_equal(r$status_code, 200)

})

