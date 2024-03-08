#Get sample data to test with dc covid clinics as example for API

vt <- tidycensus::load_variables(year = "2019", data = "acs5") |>
  dplyr::filter(geography =="tract")

test_demo <- tidycensus::get_acs(geography = "tract",
                                 state = "dc",
                                 year = 2019,
                                 variables = c("B01001H_001", #NH White
                                               "B01001I_001", #hispanic,
                                               "B01001I_002" #hispanic men
                                               )
                                 ) |>
  tidyr::pivot_wider(names_from = "variable", values_from = c("estimate", "moe")) |>
  dplyr::rename(
    nh_white_pop =  "estimate_B01001H_001",
    nh_white_pop_margin = "moe_B01001H_001",
    hispanic = "estimate_B01001I_001",
    hispanic_margin = "moe_B01001I_001",
    hispanic_men = "estimate_B01001I_002",
    hispanic_men_margin = "moe_B01001I_002"
  )

test_baseline <- tidycensus::get_acs(geography = "tract",
                                     state = "dc",
                                     year = 2019,
                                     variables = c("B05003_014", #fmale under 18
                                                   "B05003_003", #male under 18,
                                                   "B01001I_002"
                                                   )
                                     ) |>
  tidyr::pivot_wider(names_from = "variable", values_from = c("estimate", "moe")) |>
  dplyr::rename(hispanic_men = "estimate_B01001I_002",
                hispanic_men_margin = "moe_B01001I_002",
                female_under_18 = "estimate_B05003_014",
                female_under_18_margin = "moe_B05003_014",
                male_under_18 = "estimate_B05003_003",
                male_under_18_margin = "moe_B05003_003") |>
  dplyr::mutate(children = female_under_18 + male_under_18,
                children_margin =sqrt(male_under_18_margin ** 2 + female_under_18_margin ** 2))

#For test of everything in ideal set-up:
readr::write_csv(test_demo, "tests/testthat/data/dc_test_api_demographic.csv")
readr::write_csv(test_baseline, "tests/testthat/data/dc_test_api_baseline.csv")

# For incorrect file type
openxlsx::xwrite.xlsx(test_demo, "tests/testthat/data/dc_test_api_demographic.xlsx")
openxlsx::write.xlsx(test_baseline, "tests/testthat/data/dc_test_api_baseline.xlsx")

# For missing lat and lon columns
missing_lat_lon <- readr::read_csv("tests/testthat/data/dc_test_api_resource.csv") |>
  dplyr::select(-X, - Y)

readr::write_csv(missing_lat_lon, "tests/testthat/data/dc_test_api_resource_missinglatlon.csv")

#For some missing margin columns
test_demo |>
  dplyr::select(-hispanic_men_margin, -hispanic_margin) |>
  readr::write_csv("tests/testthat/data/dc_test_api_demographic-missing_margins.csv")

test_baseline |>
  dplyr::select(-male_under_18_margin, -female_under_18_margin) |>
  readr::write_csv("tests/testthat/data/dc_test_api_baseline-missing_margins.csv")

#For weight and filter:
resource_data <- read_csv("tests/testthat/data/dc_test_api_resource.csv") |>
  dplyr::mutate(filter_col = ifelse(Site_Type == "Provider Testing", "yes", "no"),
                weight_col = ifelse(is.na(LocationID), 1, LocationID)) |>
  dplyr::select(X, Y, filter_col, weight_col) |>
  readr::write_csv("tests/testthat/data/dc_test_api_resource-filter_and_weight.csv")

r2 <- read_csv("tests/testthat/data/dc_test_api_resource.csv") |>
  dplyr::mutate(new_column = 1) |>
  dplyr::select(new_column, X, Y,LocationID, EditDate) |>
  as.data.frame() |>
  dplyr::mutate(date = str_sub(EditDate, 1, 10)) |>
  dplyr::mutate(date_clean = str_c(str_sub(date, 6, 8), str_sub(date, 9, 10), "/", str_sub(date, 1, 4))) |>
  dplyr::select(new_column, X, Y, LocationID, date = date_clean) |>
  dplyr::mutate(date = as.Date(date, format = "%m/%d/%Y"))

readr::write_csv(r2, "tests/testthat/data/resource_data_3.csv")


#For files too many columns:
demo_wide <- test_demo |>
  dplyr::mutate(c1 = hispanic,
         c2 = hispanic,
         c3 = hispanic,
         c4 = hispanic,
         c5 = hispanic,
         c6 = hispanic,
         c7 = hispanic,
         c8 = hispanic,
         c9 = hispanic,
         c10 = hispanic)

baseline_wide <- test_baseline |>
  dplyr::mutate(c1 = hispanic_men,
         c2 = hispanic_men,
         c3 = hispanic_men,
         c4 = hispanic_men,
         c5 = hispanic_men,
         c6 = hispanic_men,
         c7 = hispanic_men,
         c8 = hispanic_men,
         c9 = hispanic_men,
         c10 = hispanic_men)
readr::write_csv(demo_wide, "tests/testthat/data/demographic_wide.csv")
readr::write_csv(baseline_wide, "tests/testthat/data/baseline_wide.csv")



#For Missingness but less than 50%
missing_baseline <- test_baseline |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
         hispanic_men = ifelse(row_number %% 3 == 0, NA, hispanic_men),
         male_under_18_margin = ifelse(row_number %% 3 == 0, NA, male_under_18_margin)
  ) |>
  dplyr::select(-row_number)

missing_demographic <- test_demo |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
    hispanic = ifelse(row_number %% 3 == 0, NA, hispanic),
    nh_white_pop_margin = ifelse(row_number %% 3 == 0, NA, nh_white_pop_margin)
    )

readr::write_csv(missing_baseline, "tests/testthat/data/missing_baseline-pct_33.csv")
readr::write_csv(missing_demographic, "tests/testthat/data/missing_demographic-pct_33.csv")

#Missingness at above 50%

missing_66_baseline <- test_baseline |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
                hispanic_men = ifelse(row_number %% 2 == 0 | row_number %% 3 == 0, NA, hispanic_men),
                male_under_18_margin = ifelse(row_number %% 2 == 0 | row_number %% 3 == 0, NA, male_under_18_margin))

missing_66_demographic <- test_demo |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
                hispanic = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0, NA, hispanic),
                nh_white_pop_margin = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0, NA, nh_white_pop_margin)
  )



readr::write_csv(missing_66_baseline, "tests/testthat/data/missing_baseline-pct_66.csv")
readr::write_csv(missing_66_demographic, "tests/testthat/data/missing_demographic-pct_66.csv")



#negatives:
baseline_negative <- test_baseline |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
                hispanic_men = ifelse(row_number %% 3 == 0, #impute to 0 and warn
                                      hispanic_men * -1,
                                      hispanic_men),
                female_under_18 = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0,  #Drop (and margin column)
                                         female_under_18 * -1,
                                         female_under_18),
                male_under_18_margin = ifelse(row_number %% 3 == 0, #drop but not value column
                                              male_under_18_margin * -1,
                                              male_under_18_margin)
         )

demographic_negative <- test_demo |>
  dplyr::mutate(row_number = 1:nrow(test_demo),
                hispanic_men = ifelse(row_number %% 3 == 0,
                                      hispanic * -1,
                                      hispanic), #impute to 0 and warn
                hispanic = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0, # drop (and margin column)
                                  hispanic * -1,
                                  hispanic),
                nh_white_pop_margin = ifelse(row_number %% 3 == 0, #Drop but not value column
                                             nh_white_pop_margin * -1,
                                             nh_white_pop_margin)
                )


readr::write_csv(baseline_negative, "tests/testthat/data/baseline_negative.csv")
readr::write_csv(demographic_negative, "tests/testthat/data/demographic_negative.csv")

#For above total population:
baseline_above_tot_pop_33 <- test_baseline |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
                hispanic_men = ifelse(row_number %% 3 == 0, hispanic_men + 100000, hispanic_men),
                male_under_18_margin = ifelse(row_number %% 3 == 0,
                                              male_under_18_margin * + 100000,
                                              male_under_18_margin)
  )

baseline_above_tot_pop_66 <- test_baseline |>
  dplyr::mutate(row_number = 1:nrow(test_baseline),
                hispanic_men = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0,
                                      hispanic_men + 100000,
                                      hispanic_men),
                male_under_18_margin = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0,
                                              male_under_18_margin * + 100000,
                                              male_under_18_margin)
  )

demographic_above_tot_pop_33 <- test_demo |>
  dplyr::mutate(row_number = 1:nrow(test_demo),
                hispanic = ifelse(row_number %% 3 == 0, hispanic + 100000, hispanic),
                nh_white_pop_margin = ifelse(row_number %% 3 == 0,
                                             nh_white_pop_margin * + 100000,
                                             nh_white_pop_margin)
  )

demographic_above_tot_pop_66 <- test_demo |>
  dplyr::mutate(row_number = 1:nrow(test_demo),
                hispanic = ifelse(row_number %% 3 == 0 | row_number %% 2 ==0,
                                  hispanic + 100000,
                                  hispanic),
                nh_white_pop_margin = ifelse(row_number %% 3 == 0 | row_number %% 2 == 0,
                                             nh_white_pop_margin * + 100000,
                                             nh_white_pop_margin)
  )

readr::write_csv(baseline_above_tot_pop_33, "tests/testthat/data/baseline_above_tot_pop_33.csv")
readr::write_csv(baseline_above_tot_pop_66, "tests/testthat/data/baseline_above_tot_pop_66.csv")
readr::write_csv(demographic_above_tot_pop_33, "tests/testthat/data/demographic_above_tot_pop_33.csv")
readr::write_csv(demographic_above_tot_pop_66, "tests/testthat/data/demographic_above_tot_pop_66.csv")


#Test floats:
baseline_float <- test_baseline |>
  dplyr::mutate(hispanic_men = hispanic_men * 1.3,
                male_under_18_margin = male_under_18_margin * 1.3)


demographic_float <- test_demo |>
  dplyr::mutate(hispanic = hispanic * 1.3,
                nh_white_pop_margin = nh_white_pop_margin * 1.3)



#Test non-numeric baseline and resource data

test_baseline |>
  dplyr::mutate(across(hispanic_men:children_margin, ~as.character(paste(.x, "abc")))) |>
  readr::write_csv("tests/testthat/data/baseline_non_numeric.csv")

test_demo |>
  dplyr::mutate(across(nh_white_pop:hispanic_men_margin, ~as.character(paste(.x, "abc")))) |>
  readr::write_csv("tests/testthat/data/demographic_non_numeric.csv")

