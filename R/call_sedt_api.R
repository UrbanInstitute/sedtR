#' This function takes a set of user inputs, calls the upload-user-files endpoint
#' to submit the request, then takes the file_id returned in the API response
#' and repeatedly calls the get-status endpoint until the analysis is completed
#' or an error is encountered. If an error is encountered, the function returns
#' the error message. If the analysis completes successfully, the function calls
#' the get-output-data endpoint to return the analysis results to the user.
#'
#' @param resource_file_path (string) path to location where the resource file
#'  dataset is stored. Dataset should be a csv or tsv
#' @param resource_lat_column (string) a column name in in the resource_file
#'  dataset indicating the resource latitude column
#' @param resource_lon_column (string)a column name in in the resource_file
#'  dataset indicating the resource longitude column
#' @param demographic_file_path (string) Optional: a path to the location where
#'  the demographic supplemental dataset is stored. Dataset should be a csv or tsv.
#' @param demographic_geo_id_column (string) Only necessary if a demographic
#'  file is provided. The name of the column with FIPS codes identifying the
#'  geography
#' @param demographic_columns (string representation of Python dictionary) Only
#'  necessary if a demographic file is provided. Data should be of the form
#'  "{'key':'value'}" where keys are the names of variable columns and value
#'  are either the name of their respective standard error columns or NA if the
#'  column lacks standard errors.
#' @param geographic_file_path (string) Optional: a path to the location where the
#'  supplemental geographic dataset is stored. Dataset should be either csv or tsv.
#' @param geographic_geo_id_column (string): Only necessary if there is a
#'  geographic dataset provided. The name of the column with FIPS codes identifying
#'  the geography
#' @param geographic_columns (string representation of Python dictionary) Only
#'  necessary if a geographic file is provided. Data should be of the form
#'  "{'key':'value'}" where keys are the names of variable columns and values
#'  are either the names of their respective standard error columns or NA if the
#'  column lacks standard error data.
#' @param resource_filters (string representation of Python list of dictionaries).
#'  Optional. Each dictionary has the structure {"filter_column":"[Column Name]",
#'  "filter_comparison" : "[Comparison Operator]", "filter_type":"[type]",
#'  "filter_val":"[filter value]"}. The filter-column key should be paired with
#'  a column name in the resource dataset. The filter_comparison operator should
#'  be one of the following: "==", ">=", "<=", "<", ">", "!=", or "dateRange".
#'  The filter type should be one of "string", "number" or "date." filter_val
#'  depends on the type. More broadly, the parameter allows users to input
#'  numeric-, string-, or date-based filters. For numeric filters, the
#'  filter_column should be numeric, the filter_comparison can be any of the listed
#'  alternatives except "dateRange", and the value should be a number wrapped in
#'  a string (ex.: "1"). For string filters, the filter_column should contain
#'  strings, the filter_comparison should be either "==" or "!=", and the
#'  filter_val should be a string. For date-based filters, the filter_column should
#'  contain dates, the filter_comparison should be dateRange, and the filter_val
#'  should be of the form "date1-date2".
#' @param resource_weight (string): Optional. Should be the name of a column
#'  in the resource dataset. If included, the number of resources in a geography
#'  will be weighted using this column.
#' @param geo (string): One of "city", "county", "state", or "country". Indicates
#'  the geographic level at which the analysis should be conducted.
#' @param acs_data_year (string): The tool currently has 2019 and 2021 data in it. A
#'  four digit year beginning with "20" must be inputted. If it is different than
#'  "2019" or "2021" the tool will use 2021 data.
#' @return response (list): The function wraps httr::POST() which
#'  returns a "response object" which is a list with information about the request.
#'  See the [httr documentation](api_url = "https://equity-tool-api.urban.org/api/v1/upload-user-file/")
#'  for more details.
#' @export


call_sedt_api <- function(resource_file_path,
                          resource_lat_column,
                          resource_lon_column,
                          demographic_file_path = NA,
                          demographic_geo_id_column = NA,
                          demographic_columns = NA,
                          geographic_file_path = NA,
                          geographic_geo_id_column = NA,
                          geographic_columns = NA,
                          resource_filters = NA,
                          resource_weight = NA,
                          geo = "city",
                          acs_data_year = "2021" ) {

  # submit request to API
  response <- call_upload_user_files(resource_file_path,
                                     resource_lat_column,
                                     resource_lon_column,
                                     demographic_file_path,
                                     demographic_geo_id_column,
                                     demographic_columns,
                                     geographic_file_path,
                                     geographic_geo_id_column,
                                     geographic_columns,
                                     resource_filters,
                                     resource_weight,
                                     geo,
                                     acs_data_year)

  if (response$status_code != 201L) {
    return(response$error_message)
  }

  # get file_id for submitted request
  file_id <- response$file_id

  #check status
  status_url <- stringr::str_glue("{base_url}/api/v1/get-output-data-status/{file_id}/")
  Sys.sleep(3)
  response <- httr::GET(url = status_url)
  # if the request for the status is not successful, return error
  if (response$status_code != 200) {
    return("There has beeen an error")
  }

  status_json <- httr::content(response, as = "text")
  status_list <- rjson::fromJSON(status_json)

  counter <- 0
  # it can sometimes take a few seconds for the status file to be present
  # the program checks if the file exists, and if not waits a few seconds
  # then tries again
  while (!status_list$results$file_exists && counter < 10) {
    Sys.sleep(3)
    response <- httr::GET(url = status_url)
    counter <- counter + 1
    status_json <- httr::content(response, as = "text")
    status_list <- rjson::fromJSON(status_json)
  }

  # test if there is no error message and if job is finished
  no_error <- !any(unlist(status_list$results$formdata$`error-messages`))
  not_finished <- !status_list$results$formdata$updates$finished
  counter <- 0

  while (no_error && not_finished && counter < 50) {

    response <- httr::GET(url = status_url)

    status_json <- httr::content(response, as = "text")
    status_list <- rjson::fromJSON(status_json)

    no_error <- all(!unlist(status_list$results$formdata$`error-messages`))
    not_finished <- !status_list$results$formdata$updates$finished
    Sys.sleep(2)

    counter <- counter + 1

  }

  # if the job finished, get the file
  if (!not_finished) {
    print("getting output file")
    return(get_output_data(file_id))
  } else {
    print("hit an error!")
    r_json <- httr::content(response, as = "text")
    error_text <- rjson::fromJSON(r_json)
    return(stringr::str_glue("The analysis for your uploaded data did not succeed. The error is {error_text}"))
  }
}
