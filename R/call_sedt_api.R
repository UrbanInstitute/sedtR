#' Call the SEDT API and return a response object
#'
#' [call_sedt_api()] takes a set of user inputs, calls the API upload-user-files
#' endpoint to submit the request, then takes the file_id returned in the API
#' response and repeatedly calls the get-status endpoint until the analysis is
#' completed or an error is encountered. If an error is encountered, the
#' function returns the error message. If the analysis completes successfully,
#' the function calls the get-output-data endpoint to return the analysis
#' results to the user.
#'
#' @inheritParams call_upload_user_files
#' @return response (list): The function wraps [httr::POST()] which
#'  returns a "response object" which is a list with information about the request.
#'  See the [API documentation](https://ui-research.github.io/sedt_documentation/api_documentation.html)
#'  for more details.
#' @inherit prep_sedt_resource details
#' @export

call_sedt_api <- function(resource = NULL,
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
                          placement = "surface",
                          ...) {
  # submit request to API
  response <- call_upload_user_files(
    resource = resource,
    resource_file_path = resource_file_path,
    resource_lat_column = resource_lat_column,
    resource_lon_column = resource_lon_column,
    demographic_file_path = demographic_file_path,
    demographic_geo_id_column = demographic_geo_id_column,
    demographic_columns = demographic_columns,
    geographic_file_path = geographic_file_path,
    geographic_geo_id_column = geographic_geo_id_column,
    geographic_columns = geographic_columns,
    resource_filters = resource_filters,
    resource_weight = resource_weight,
    geo = geo,
    acs_data_year = acs_data_year,
    placement = placement,
    ...
  )

  if (response$status_code != 201L) {
    return(response$error_message)
  }

  # get file_id for submitted request
  file_id <- response$file_id

  #check status
  status_url <- sedt_url("get-output-data-status/{file_id}/")
  Sys.sleep(3)
  response <- httr::GET(url = status_url)
  # if the request for the status is not successful, return error
  if (response$status_code != 200) {
    return("There has beeen an error")
  }

  status_json <- httr::content(response, as = "text", encoding = "UTF-8")
  status_list <- rjson::fromJSON(status_json)

  counter <- 0
  # it can sometimes take a few seconds for the status file to be present
  # the program checks if the file exists, and if not waits a few seconds
  # then tries again
  while (!status_list$results$file_exists && counter < 10) {
    Sys.sleep(3)
    response <- httr::GET(url = status_url)
    counter <- counter + 1
    status_json <- httr::content(response, as = "text", encoding = "UTF-8")
    status_list <- rjson::fromJSON(status_json)
  }

  # test if there is no error message and if job is finished
  no_error <- !any(unlist(status_list$results$formdata$`error-messages`))
  not_finished <- !status_list$results$formdata$updates$finished
  counter <- 0

  while (no_error && not_finished && counter < 50) {

    response <- httr::GET(url = status_url)

    status_json <- httr::content(response, as = "text", encoding = "UTF-8")

    status_list <- rjson::fromJSON(status_json)

    no_error <- all(!unlist(status_list$results$formdata$`error-messages`))
    not_finished <- !status_list$results$formdata$updates$finished
    Sys.sleep(2)

    counter <- counter + 1

  }

  # if the job finished, get the file
  if (!not_finished) {
    inform("getting output file")
    return(get_output_data(file_id))
  } else {
    # cli::cli_abort("hit an error!")
    r_json <- httr::content(response, as = "text", encoding = "UTF-8")
    error_text <- rjson::fromJSON(r_json)
    message <- stringr::str_glue("The analysis for your uploaded data did not succeed. The error is {error_text}")
    return(abort(message))
  }
}
