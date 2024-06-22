# sedtR (development)

- Add `resource` argument to `call_sedt_api()` that supports a wider range of resource inputs: URLs (including ArcGIS FeatureLayer and Table URLs), spatial data file paths, `sf` or `sfc` object, and data frames with columns matching the supplied `resource_lat_column` and `resource_lon_column` values. All input data must use POINT geometry. See `arcgislayers::arc_read()` for more on working with ArcGIS layer URLs.
- Add default values ("lat" and "lon") for `resource_lat_column` and `resource_lon_column`.
- Allow users to set default `acs_data_year` using the `"sedtR.year"` option.
- Use .onAttach intead of .onLoad for package start-up messages ([consistent with guidance](https://r-pkgs.org/code.html#sec-code-r-landscape))

# sedtR 0.0.0.2

- Fix installation issue with `urbnthemes` package 
- Fix package misspellings in `tests/create_dc_test_data.R`

# sedtR 0.0.3 

- Polish package readme to be more user-friendly
- Remove `urbnthemes` from `create_demo_chart()`
- Implement best practices suggested by Eli Pousson (elipousson)
