% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/call_sedt_api.R
\name{call_sedt_api}
\alias{call_sedt_api}
\title{Call the SEDT API and return a response object}
\usage{
call_sedt_api(
  resource = NULL,
  resource_file_path = NULL,
  resource_lat_column = "lat",
  resource_lon_column = "lon",
  demographic_file_path = NA,
  demographic_geo_id_column = NA,
  demographic_columns = NA,
  geographic_file_path = NA,
  geographic_geo_id_column = NA,
  geographic_columns = NA,
  resource_filters = NA,
  resource_weight = NA,
  geo = "city",
  acs_data_year = getOption("sedtR.year", 2021),
  ...
)
}
\arguments{
\item{resource}{A URL, file path, sf or sfc object, or a data frame with
\code{coords} columns. See details for more information.}

\item{resource_file_path}{(string) Default \code{NULL}. File path to location
where the resource file dataset is stored. Dataset should be a csv or tsv.
Optional if \code{resource} is provided.}

\item{resource_lat_column}{(string) Default "lat". a column name in in the
resource_file dataset indicating the resource latitude column.}

\item{resource_lon_column}{(string) Default "lon". a column name in in the
resource_file dataset indicating the resource longitude column}

\item{demographic_file_path}{(string) Optional: a path to the location where
the demographic supplemental dataset is stored. Dataset should be a csv or
tsv.}

\item{demographic_geo_id_column}{(string) Only necessary if a demographic
file is provided. The name of the column with FIPS codes identifying the
geography}

\item{demographic_columns}{(string representation of Python dictionary) Only
necessary if a demographic file is provided. Data should be of the form
"{'key':'value'}" where keys are the names of variable columns and value
are either the name of their respective standard error columns or NA if the
column lacks standard errors.}

\item{geographic_file_path}{(string) Optional: a path to the location where
the supplemental geographic dataset is stored. Dataset should be either csv
or tsv.}

\item{geographic_geo_id_column}{(string): Required if there is a geographic
dataset provided. The name of the column with FIPS codes identifying the
geography}

\item{geographic_columns}{(string representation of Python dictionary) Only
necessary if a geographic file is provided. Data should be of the form
"{'key':'value'}" where keys are the names of variable columns and values
are either the names of their respective standard error columns or NA if the
column lacks standard error data.}

\item{resource_filters}{(string representation of Python list of
dictionaries).
Optional. Each dictionary has the structure {"filter_column":"[Column Name]",
"filter_comparison" : "[Comparison Operator]", "filter_type":"[type]",
"filter_val":"[filter value]"}. The filter-column key should be paired with
a column name in the resource dataset. The filter_comparison operator
should be one of the following: "==", ">=", "<=", "<", ">", "!=", or
"dateRange". The filter type should be one of "string", "number" or "date."
filter_val depends on the type. More broadly, the parameter allows users to
input numeric-, string-, or date-based filters. For numeric filters, the
filter_column should be numeric, the filter_comparison can be any of the
listed alternatives except "dateRange", and the value should be a number
wrapped in a string (ex.: "1"). For string filters, the filter_column
should contain strings, the filter_comparison should be either "==" or
"!=", and the filter_val should be a string. For date-based filters, the
filter_column should contain dates, the filter_comparison should be
dateRange, and the filter_val should be of the form "date1-date2".}

\item{resource_weight}{(string): Optional. Should be the name of a column in
the resource dataset. If included, the number of resources in a geography
will be weighted using this column. Can't be used if resource is a \code{sfc}
object.}

\item{geo}{(string): One of "city", "county", "state", or "country".
Indicates the geographic level at which the analysis should be conducted.}

\item{acs_data_year}{(string or integer): The tool currently has 2019 and
2021 data in it. A four digit year beginning with "20" must be inputted. If
it is different than "2019" or "2021" the tool will use 2021 data. A
default value can be set using the "sedtR.year" option.}

\item{...}{Additional parameters passed to \code{\link[arcgislayers:arc_read]{arcgislayers::arc_read()}} or
\code{\link[sf:st_read]{sf::st_read()}} depending on the value provided to \code{resource}.}
}
\value{
response (list): The function wraps \code{\link[httr:POST]{httr::POST()}} which returns a
"response object" which is a list with information about the request. See
the \href{https://ui-research.github.io/sedt_documentation/api_documentation.html}{API documentation}
for more details.
}
\description{
\code{\link[=call_sedt_api]{call_sedt_api()}} takes a set of user inputs, calls the API upload-user-files
endpoint to submit the request, then takes the file_id returned in the API
response and repeatedly calls the get-status endpoint until the analysis is
completed or an error is encountered. If an error is encountered, the
function returns the error message. If the analysis completes successfully,
the function calls the get-output-data endpoint to return the analysis
results to the user.
}
\details{
Valid resource inputs

To call the Spatial Equity Data Tool API, \code{\link[=call_sedt_api]{call_sedt_api()}} requires a CSV or
TSV input file with coordinate attribute columns. \code{\link[=prep_sedt_resource]{prep_sedt_resource()}} also allows users to alternatively supply:
\itemize{
\item A URL for a delimited file with coordinate columns or a spatial data file
\item A ArcGIS FeatureLayer or Table URL (read with \code{\link[arcgislayers:arc_read]{arcgislayers::arc_read()}})
\item A file path for a spatial or tabular data file that can be read with \code{\link[sf:st_read]{sf::read_sf()}}
\item A data frame containing the named columns in \code{coords}
\item A \code{sf} or \code{sfc} object with POINT geometry that can be converted to a data frame using \code{\link[sf:st_coordinates]{sf::st_coordinates()}}
}

If resource is an \code{sf} object or a path to a spatial data file with POLYGON,
MULTIPOLYGON, or any non-POINT geometry, \code{placement} is used to convert the
input into points. \code{\link[sf:geos_unary]{sf::st_centroid()}} (if \code{placement = "centroid"}) or
\code{\link[sf:geos_unary]{sf::st_point_on_surface()}} (if \code{placement = "surface"} which is the default)
option.
}
