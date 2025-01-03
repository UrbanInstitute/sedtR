create_sample_data <- function(){
  # supplemental geographic data

  #DC City data:
  dem_city <- tidycensus::get_acs(geography = "tract",
                                  state = "11",
                                  county = "001",
                                  output = "wide",
                                  year = 2019,
                                  variables = c(
                                    "num_black" = "B03002_004",
                                    "num_white" = "B03002_003",
                                    "num_seniors" = "DP05_0024",
                                    "num_asian" = "DP05_0080",
                                    "num_children" = "DP05_0019",
                                    "num_hisp" = "DP05_0071"
                                  ))
  readr::write_csv(dem_city, "tests/testthat/data/test_api_dem_city.csv")


  # Miami-Dade County
  geo_county <- tidycensus::get_acs(geography = "tract",
                                    state = "12",
                                    county = "086",
                                    year = 2021,
                                    output = "wide",
                                    variables = c("male_under_5" = "B01001_003",
                                                  "female_under_5" = "B01001_027",
                                                  "masters_degree" = "B15003_023",
                                                  "owner_occupied" = "B25003_002"))

  readr::write_csv(geo_county, "tests/testthat/data/test_api_geo_county.csv")

  dem_county <- tidycensus::get_acs(geography = "tract",
                                    state = "12",
                                    year = 2021,
                                    county = "086",
                                    output = "wide",
                                    variables = c(
                                      "num_black" = "B03002_004",
                                      "num_white" = "B03002_003",
                                      "num_seniors" = "DP05_0024",
                                      "num_asian" = "DP05_0080",
                                      "num_children" = "DP05_0019",
                                      "num_hisp" = "DP05_0071"
                                    ))
  readr::write_csv(dem_county, "tests/testthat/data/test_api_dem_county.csv")

  # Washington State
  geo_state <- tidycensus::get_acs(geography = "county",
                                   state = "53",
                                   year = 2021,
                                   output = "wide",
                                   variables = c("male_under_5" = "B01001_003",
                                                 "female_under_5" = "B01001_027",
                                                 "masters_degree" = "B15003_023",
                                                 "owner_occupied" = "B25003_002"))

  readr::write_csv(geo_state, "tests/testthat/data/test_api_geo_state.csv")

  # National
  geo_national <- tidycensus::get_acs(geography = "state",
                                      year = 2021,
                                      output = "wide",
                                      variables = c("male_under_5" = "B01001_003",
                                                    "female_under_5" = "B01001_027",
                                                    "masters_degree" = "B15003_023",
                                                    "owner_occupied" = "B25003_002")) %>%
    dplyr::filter(GEOID != "72")

  readr::write_csv(geo_national, "tests/testthat/data/test_api_geo_national.csv")

  # Washington State
  dem_state <- tidycensus::get_acs(geography = "tract",
                                   state = "53",
                                   year = 2021,
                                   output = "wide",
                                   variables = c(
                                                 "num_black" = "B03002_004",
                                                 "num_white" = "B03002_003",
                                                 "num_seniors" = "DP05_0024",
                                                 "num_asian" = "DP05_0080",
                                                 "num_children" = "DP05_0019",
                                                 "num_hisp" = "DP05_0071"
                                                 ))

  readr::write_csv(dem_state, "tests/testthat/data/test_api_dem_state.csv")

  # National
  state_codes <- tidycensus::fips_codes %>%
    dplyr::filter(as.numeric(state_code) <= 56) %>%
    dplyr::pull(state_code) %>%
    unique()

  dem_national <- purrr::map_dfr(state_codes,
                                ~tidycensus::get_acs(
                                  geography = "tract",
                                  state = .x,
                                  year = 2021,
                                  output = "wide",
                                  variables = c(
                                    "num_black" = "B03002_004",
                                    "num_white" = "B03002_003",
                                    "num_seniors" = "DP05_0024",
                                    "num_asian" = "DP05_0080",
                                    "num_children" = "DP05_0019",
                                    "num_hisp" = "DP05_0071"
                                  )))

  readr::write_csv(dem_national, "tests/testthat/data/test_api_dem_national.csv")

  # filter mental health facilities to washington

  wa_mental_health <- readr::read_csv("https://equity-tool-api-stg.urban.org/sample-data/wa_mental_health.csv") %>%
    dplyr::filter(state == "WA")

  readr::write_csv(wa_mental_health, "tests/testthat/data/wa_mental_health.csv")

}
