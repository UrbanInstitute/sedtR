test_that("prep_sedt_resource errors with invalid inputs", {
  nc = sf::read_sf(system.file("shape/nc.shp", package="sf"))

  # Error on non-POINT geometry
  expect_error(
    prep_sedt_resource(nc)
  )

  # Error on nonexistent file path
  expect_error(
    prep_sedt_resource("non-existent.csv")
  )
})

test_that("prep_sedt_resource works with valid inputs", {
  nc_path <- system.file("shape/nc.shp", package="sf")
  nc = sf::read_sf(nc_path)
  nc_points <- suppressWarnings(sf::st_centroid(nc))

  # Works with file path for POINT geometry
  expect_true(
    file.exists(prep_sedt_resource(system.file("gpkg/b_pump.gpkg", package="sf")))
  )

  # Works with POINT geometry input
  expect_true(
    file.exists(prep_sedt_resource(nc_points))
  )

  subway_station_url <- "https://services6.arcgis.com/yG5s3afENB5iO9fj/arcgis/rest/services/SubwayStation_view/FeatureServer/0"

  # Works with URL
  expect_error(
    prep_sedt_resource(subway_station_url)
  )
})
