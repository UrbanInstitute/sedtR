#' Get API Response
#'
#' Calls call_upload_user_files() for a given file path, lat col,
#' and lon col, parses and returns API response
#'
#' @param param_list (string) Required: Includes the parameters included in the call_upload_user_files function
#'
#' @return r (string) Returns the API error status code response

get_api_response <- function(param_list) {

  r <- call_upload_user_files(
    resource_file_path = param_list[["resource_file_path"]],
    resource_lat_column = param_list[["resource_lat_column"]],
    resource_lon_column = param_list[["resource_lon_column"]],
    geo = param_list[["geo"]],
    acs_data_year = param_list[["acs_data_year"]],
    demographic_file_path = param_list[["demographic_file_path"]],
    demographic_geo_id_column = param_list[["demographic_geo_id_column"]],
    demographic_columns = param_list[["demographic_columns"]],
    geographic_file_path = param_list[["geographic_file_path"]],
    geographic_geo_id_column = param_list[["geographic_geo_id_column"]],
    geographic_columns = param_list[["geographic_columns"]],
    resource_filters = param_list[["resource_filters"]],
    resource_weight = param_list[["resource_weight"]]
  )

  return(r)


}

#' Is Valid Col Type
#'
#' Tests if the value of the baseline columns or demographic columns
#' dictionaries has a valid data type
#'
#' @param col_name (string or NULL object)
#'
#' @return (boolean)
#' @export
#'
is_valid_col_type <- function(col_name) {

  if (is.na(col_name)) {
    return(TRUE)
  } else {
    return(is.character(col_name))
  }

}

#' Convert values that we consider valid missing values to the NULL object
#'
#' @param col_name (string or NULL object)
#'
#' @return col_name (string or NULL object)
#' @export
#'
convert_to_na <- function(col_name) {
  if (is.list(col_name) && length(col_name) > 0L) {
    # if a non-empty list, return col_name
    return(col_name)
  } else if (is.list(col_name)) {
    # if empty list return NA
    return(NA)
  } else if (is.null(col_name)) {
    # if NULL return NA
    return(NA)
  } else if (is.na(col_name)) {
    # if NA return NA
    return(NA)
  } else if (col_name == "") {
    # if empty string return NA
    return(NA)
  } else {
    # otherwise return col_name
    return(col_name)
  }

}

get_api_results <- function(file_id) {
  #check status
  status_url <- stringr::str_glue("{base_url}/api/v1/get-output-data-status/{file_id}/")
  Sys.sleep(3L)
  response <- httr::GET(url = status_url)
  # if the request for the status is not successful, return error
  if (response[["status_code"]] != 200L) {
    return("There has beeen an error")
  }

  status_json <- httr::content(response, as = "text")
  status_list <- rjson::fromJSON(status_json)

  counter <- 0L
  # it can sometimes take a few seconds for the status file to be present
  # the program checks if the file exists, and if not waits a few seconds
  # then tries again
  while (!status_list[["results"]][["file_exists"]] && counter < 10L) {
    Sys.sleep(3L)
    response <- httr::GET(url = status_url)
    counter <- counter + 1L
    status_json <- httr::content(response, as = "text")
    status_list <- rjson::fromJSON(status_json)
  }

  # test if there is no error message and if job is finished
  no_error <- !any(unlist(status_list[["results"]][["formdata"]][["error-messages"]]))
  finished <- status_list[["results"]][["formdata"]][["updates"]][["finished"]]
  counter <- 0L

  while (no_error && !finished && counter < 50L) {

    response <- httr::GET(url = status_url)

    status_json <- httr::content(response, as = "text")
    status_list <- rjson::fromJSON(status_json)

    no_error <- !any(unlist(status_list[["results"]][["formdata"]][["error-messages"]]))
    finished <- status_list[["results"]][["formdata"]][["updates"]][["finished"]]
    Sys.sleep(2L)

    counter <- counter + 1L

  }

  if (finished) {
    # if the job finished, get the file
    print("getting output file")
    #get file
    output_data_url <- stringr::str_glue("{base_url}/api/v1/get-output-data/{file_id}/")

    response <- httr::GET(
      url = output_data_url
    )
    r_json <- httr::content(response, as = "text")
    r_list <- rjson::fromJSON(r_json)
    file_exists <- r_list[["results"]][["file_exists"]]

    if (file_exists) {
      print("parsing output result")

      geo <- r_list[["results"]][["result"]][["geo_bias_data"]] |> #access geo bias data from list
        rjson::toJSON() |> #convert back to JSON for geojsonsf to read
        geojsonsf::geojson_sf() #Convert from json format to sf dataframe

      demo <- r_list[["results"]][["result"]][["demographic_bias_data"]] |>
        rjson::toJSON() |>
        jsonlite::fromJSON() |>
        as.data.frame()


      df_list <- list(
        dd = demo,
        gd = geo,
        full_api_results = r_list
      )

      return(df_list)

    } else {
      print("hit an error!")
      r_json <- httr::content(response, as = "text")
      error_text <- rjson::fromJSON(r_json)
      return_message <- stringr::str_glue("The analysis for your uploaded data did not succeed. The error is {error_text}")
      return(return_message)
    }
  } else {
    print("hit an error!")
    error_messages <- paste(names(lapply(status_list[["results"]][["formdata"]][["error-messages"]], function(x) x[isTRUE(x)])), " ")
    return_message <- stringr::str_glue("The analysis for your uploaded data did not succeed. The error is {error_messages}")
    return(return_message)

  }
}
