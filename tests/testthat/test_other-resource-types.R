test_that("test call_sedt_api works with non-file resources", {
  library(gpkg)
  nc = sf::read_sf(system.file("shape/nc.shp", package="sf"))
  nc_path <- system.file("shape/nc.shp", package="sf")
  nc = sf::read_sf(nc_path)
  nc_points <- suppressWarnings(sf::st_centroid(nc))

  if(!file.exists("data/nc_points.csv")){
    nc_points |>
      sf::st_transform(4326) |>
      sf::st_coordinates() |>
      as.data.frame() |>
      set_names(c("lon", "lat")) |>
      readr::write_csv("data/nc_points.csv")
  }


  # test sf object
  sedt_response_sf <- call_sedt_api(
    resource = nc_points,
    geo = "state",
    acs_data_year = 2021
  )

  testthat::expect_no_error(sedt_response_sf$geo_bias_data)
  testthat::expect_no_error(sedt_response_sf$demo_bias_data)

  gpkg_tmp <- tempfile(fileext = ".gpkg")

  gpkg::gpkg_write(nc_points,
           destfile = gpkg_tmp,
           append = TRUE,
           creation_options = gpkg::gpkg_creation_options)

  # test geopackage
  sedt_response_gpkg <- call_sedt_api(
    resource = gpkg_tmp,
    geo = "state",
    acs_data_year = 2021
  )

  file.remove(gpkg_tmp)

  # test that different formats of same data give same result
  testthat::expect_no_error(sedt_response_gpkg$geo_bias_data)
  testthat::expect_no_error(sedt_response_gpkg$demo_bias_data)

  sedt_response_csv <- call_sedt_api(
    resource = "data/nc_points.csv",
    geo = "state",
    acs_data_year = 2021
  )

  testthat::expect_equal(
    sedt_response_gpkg$geo_bias_data,
    sedt_response_sf$geo_bias_data
    )

  testthat::expect_equal(
    sedt_response_gpkg$geo_bias_data,
    sedt_response_csv$geo_bias_data
  )

  testthat::expect_equal(
    sedt_response_gpkg$demo_bias_data,
    sedt_response_sf$demo_bias_data
  )


  testthat::expect_equal(
    sedt_response_gpkg$demo_bias_data,
    sedt_response_csv$demo_bias_data
  )




  # test ArcGIS feature service

  subway_station_url <- "https://services6.arcgis.com/yG5s3afENB5iO9fj/arcgis/rest/services/SubwayStation_view/FeatureServer/0"

  sedt_response <- call_sedt_api(
    resource = subway_station_url,
    geo = "city",
    acs_data_year = 2022
  )

  testthat::expect_no_error(sedt_response$geo_bias_data)
  testthat::expect_no_error(sedt_response$demo_bias_data)



}
)
