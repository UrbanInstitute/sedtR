# sedtR 0.4.0

- Introduces beta functionality to allow users to use a travel shed approach for SEDT analyses. The functionality is being tested and is available at the county and city scale for datasets in the District of Columbia, Virginia, and Maryland. Urban hopes to expand the functionality to all states soon. For more information, see the [travel sheds documentation](https://ui-research.github.io/sedt_documentation/using_sheds.html)
- Adds `distance_mode` and `distance_time` arguments to `call_upload_user_files()` and `call_sedt_api()` functions to set travel mode ("walk" or "drive") and the maximum travel time for travel shed analyses. 

# sedtR 0.3.0

- Add `resource` argument to `call_sedt_api()` that supports a wider range of resource inputs: URLs (including ArcGIS FeatureLayer and Table URLs), spatial data file paths, `sf` or `sfc` object, and data frames with columns matching the supplied `resource_lat_column` and `resource_lon_column` values. All input data must use POINT geometry. See `arcgislayers::arc_read()` for more on working with ArcGIS layer URLs.
- Add default values ("lat" and "lon") for `resource_lat_column` and `resource_lon_column`.
- Allow users to set default `acs_data_year` using the `"sedtR.year"` option.
- Use .onAttach intead of .onLoad for package start-up messages ([consistent with guidance](https://r-pkgs.org/code.html#sec-code-r-landscape))

# sedtR 0.2.0 
- Makes `create_demo_chart()` and `create_map()` operational
- Provides description of how to use `create_demo_chart()` and `create_map()` on the README 

# sedtR 0.1.2 

- Polish package readme to be more user-friendly
- Remove `urbnthemes` from `create_demo_chart()`
- Implement best practices suggested by Eli Pousson (elipousson)

# sedtR 0.1.1

- Fix installation issue with `urbnthemes` package 
- Fix package misspellings in `tests/create_dc_test_data.R`

# sedtR 0.1.0

- First release
