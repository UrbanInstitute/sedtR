#Create large files for large file test:

create_big_data <- function() {
  #read large files:
  test_demo <- readr::read_csv(here::here("tests", "testthat", "data", "dc_test_api_demographic.csv"))
  test_geographic <- readr::read_csv(here::here("tests", "testthat", "data", "dc_test_api_geographic.csv"))
  test_resource <- test_geographic |>
    dplyr::rename(X = NAME,
                  Y = hispanic_men)




  #For large files:
  geographic_big <- do.call("rbind", replicate(12000, test_geographic, simplify = FALSE))
  readr::write_csv(geographic_big, here::here("tests", "testthat", "data", "dc_test_api_geographic_big.csv"))

  demographic_big <- do.call("rbind", replicate(12000, test_demo, simplify = FALSE))
  readr::write_csv(demographic_big, here::here("tests", "testthat", "data", "dc_test_api_demographic_big.csv"))

  resource_big <- do.call("rbind", replicate(12000, test_resource, simplify = FALSE))
  readr::write_csv(resource_big, here::here("tests", "testthat", "data", "dc_test_api_resource_big.csv"))

}
