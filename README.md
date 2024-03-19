
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sedtR

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

### Purpose of `sedtR`:

The `sedtR` package allows R programmers to easily interact with Urban’s
[Spatial Equity Data
Tool](https://apps.urban.org/features/equity-data-tool/) (SEDT) [public
application programming
interface](https://ui-research.github.io/sedt_documentation/api_documentation.html)
(API).

## Background

### What is the Spatial Equity Data Tool?

The SEDT enables local, state, and federal leaders, as well as the
general public, to upload their own point spatial data and quickly
assess whether place-based programs and resources – such as parks,
libraries, wi-fi hotspots or electric vehicle charging stations – are
equitably distributed across neighborhoods and demographic groups.

The tool – launched in 2020 and expanded in 2021 – has been used by a
wide variety of experts and nonexperts alike to assess equity in the
distribution of local programs and resources. For example, the
Bloomington Pedestrian and Bicycle Safety Commission analyzed sidewalk
funding allocations, and advocates in Cincinnati identified economic and
racial inequities in car crash locations.

### Why Create a Public API and `sedtR`:

Through engagements with local government and nonprofit users, we
identified a key barrier. Organizations wanted to embed the SEDT within
their own tools and data workflows and thus make the Tool a core part of
institutional processes. However, before the API’s release in March of
2024, Tool users would have had to visit Urban’s website and use the GUI
interface to upload one dataset at a time whenever new analyses were
needed. The release of the API overcomes this barrier by allowing
programmatic access to the Tool. We wrote `sedtR` to wrap the public
API’s endpoints in user-friendly R code. We are hopeful that `sedtR`
makes it easy for researchers, analysts, and policymakers to incorporate
SEDT calculations into R workflows.

## Installation

You can install the development version of sedtR from
[GitHub](https://github.com/) with:

## Example

The following example illustrates using the `call_sedt_api()` function
on Minneapolis, MN bikeshare data stored on the Urban Institute’s [Data
Catalog](https://datacatalog.urban.org/).

    #> Loading sedtR  - using  production  API
    #> [1] "getting output file"

`call_sedt_api()` returns a list object contains a `sf` object that can
be visualized using `create_map()` and `create_demo_chart()`:

``` r
create_map(sedt_response$geo_bias_data, save_map = FALSE, interactive = FALSE)
#> An Error Occurred
#> <simpleError in sym(col_to_plot): could not find function "sym">
```

``` r
create_demo_chart(sedt_response$demo_bias_data)
#> An Error Occurred
#> <simpleError in gpar(fontface = "bold", fontfamily = "Lato", col = palette_urbn_diverging[7],     fontsize = 22, alpha = 0.75): could not find function "gpar">
```

A data frame with demographic information used in the analysis is also
returned:

``` r
sedt_response$demo_bias_data |>
  head()
#>                   census_var data_value summary_value diff_data_city
#> 1            pct_no_internet    8.78435         7.752        1.03235
#> 2 pct_under_200_poverty_line   37.70731        33.240        4.46731
#> 3        pct_all_other_races    6.23852         6.280       -0.04148
#> 4        pct_less_hs_diploma   10.10677         9.295        0.81177
#> 5          pct_under18_unins    4.50332         3.074        1.42932
#> 6            pct_under18_pov   19.22721        21.193       -1.96579
#>   data_value_sd summary_value_margin sig_diff  geo geo_fips     geo_display
#> 1       0.54109                0.508    FALSE city  2743000 Minneapolis, MN
#> 2       0.74891                0.955     TRUE city  2743000 Minneapolis, MN
#> 3       0.32612                0.395    FALSE city  2743000 Minneapolis, MN
#> 4       0.62023                0.532    FALSE city  2743000 Minneapolis, MN
#> 5       1.49243                0.495    FALSE city  2743000 Minneapolis, MN
#> 6       2.10830                1.697    FALSE city  2743000 Minneapolis, MN
#>   geo_mo baseline_pop
#> 1   null    total_pop
#> 2   null    total_pop
#> 3   null    total_pop
#> 4   null    total_pop
#> 5   null  under18_pop
#> 6   null  under18_pop
```

## Where Can I Learn More:

The Spatial Equity Data Tool has comprehensive documentation in the form
of an [online book](https://ui-research.github.io/sedt_documentation/).
Most notably, there is a chapter [specifically devoted to the
API](https://ui-research.github.io/sedt_documentation/api_documentation.html).
It provides more in-depth `sedtR` code and outputs.

Other particularly relevant chapters cover [common API errors and
warnings](https://ui-research.github.io/sedt_documentation/common_errors_warnings.html),
[how to interpret Tool
results](https://ui-research.github.io/sedt_documentation/interpreting_results.html),
and a [description of data appropriate for the
Tool](https://ui-research.github.io/sedt_documentation/resource_datasets.html).

## Feedback:

Please provide feedback by opening [GitHub
Issues](https://github.com/UrbanInstitute/sedtR/issues) or contacting us
at <sedt@urban.org>.
