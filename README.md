
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sedtR

<!-- badges: start -->
<!-- badges: end -->

### Purpose of `sedtR`:

We created the `sedtR` package to allow R programmers to easily interact
with Urban’s Spatial Equity Data Tool (SEDT) application programming
interface (API).

### Heads up: Package Under Construction
While the workhorse functions in this package are operational and pass 
an extensive suite of tests, this package should be considered in 
`beta` version for the time being. Please create an issue or email
`sedt@urban.org` if you have questions or see issues in the code. 

#### What is the Spatial Equity Data Tool:

The SEDT enables local, state, and federal leaders, as well as the
general public, to upload their own point spatial data and quickly
assess whether place-based programs and resources – such as parks,
libraries, wi-fi hotspots or electric vehicle charging stations – are
equitably distributed across neighborhoods and demographic groups. The
tool – launched in 2020 and expanded in 2021 – has been used by a wide
variety of experts and nonexperts alike to assess equity in the
distribution of local programs and resources. For example, the
Bloomington Pedestrian and Bicycle Safety Commission analyzed sidewalk
funding allocations, and advocates in Cincinnati identified economic and
racial inequities in car crash locations.

#### Why Create a Public API and `sedtR`:

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

### Installation

You can install the development version of sedtR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("UrbanInstitute/sedtR")
```

### Example

The following example illustrates using the `call_sedt_api()` function
on Minneapolis, MN bikeshare data stored on the Urban Institute’s [Data
Catalog](https://datacatalog.urban.org/).

``` r
library(sedtR)

#download bicycle data:
download.file("https://equity-tool-api.urban.org/sample-data/minneapolis_bikes.csv", 
              destfile = "bikes.csv")

#call sedt API with wrapper function
sedt_response <- sedtR::call_sedt_api(
  resource_file_path = here::here("bikes.csv"),
  resource_lat_column = "lat",
  resource_lon_column = "lon",
  geo = "city",
  acs_data_year = "2021")

#delete downloaded file:
file.remove("bikes.csv")
```

### Where Can I Learn More:

The Spatial Equity Data Tool has comprehensive documentation in the form
of an [online book](https://ui-research.github.io/sedt_documentation/).
Most notably, there is a chapter [specifically devoted to the
API](https://ui-research.github.io/sedt_documentation/api_documentation.html).
It provides more in-depth `sedtR` code and outputs. Other particularly
relevant chapters cover [common API errors and
warnings](https://ui-research.github.io/sedt_documentation/common_errors_warnings.html),
[how to interpret Tool
results](https://ui-research.github.io/sedt_documentation/interpreting_results.html),
and a [description of data appropriate for the
Tool](https://ui-research.github.io/sedt_documentation/resource_datasets.html).

### Feedback:

Please provide feedback by opening [GitHub
Issues](https://github.com/UrbanInstitute/sedtR/issues) or contacting us
at <sedt@urban.org>.
