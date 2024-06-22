#' Get API Response
#'
#' Calls [call_upload_user_files()] for a given file path, lat col,
#' and lon col, parses and returns API response
#'
#' @param param_list (string) Required: Includes the parameters included in the
#'   call_upload_user_files function
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
  status_list <- get_status(file_id)

  counter <- 0L
  # it can sometimes take a few seconds for the status file to be present
  # the program checks if the file exists, and if not waits a few seconds
  # then tries again
  while (!status_list[["results"]][["file_exists"]] && counter < 10L) {
    Sys.sleep(3L)
    status_list <- get_status(file_id)
    counter <- counter + 1L
  }

  # test if there is no error message and if job is finished
  no_error <- !any(unlist(status_list[["results"]][["formdata"]][["error-messages"]]))
  finished <- status_list[["results"]][["formdata"]][["updates"]][["finished"]]
  counter <- 0L

  while (no_error && !finished && counter < 50L) {

    status_list <- get_status(file_id)
    no_error <- !any(unlist(status_list[["results"]][["formdata"]][["error-messages"]]))
    finished <- status_list[["results"]][["formdata"]][["updates"]][["finished"]]
    Sys.sleep(2L)

    counter <- counter + 1L

  }

  if (finished) {
    # if the job finished, get the file
    print("getting output file")
    #get file
    output_data <- get_output_data(file_id)
    return(output_data)

  } else {
    print("hit an error!")
    error_messages <- paste(names(lapply(status_list[["results"]][["formdata"]][["error-messages"]], function(x) x[isTRUE(x)])), " ")
    return_message <- stringr::str_glue("The analysis for your uploaded data did not succeed. The error is {error_messages}")
    return(return_message)

  }
}

#' Does x match the pattern of a delimited data file path?
#' @noRd
is_delim_path <- function(path) {
  grepl("\\.(csv|tsv)", path)
}

#' Does x match the pattern of a URL?
#' @noRd
is_url <- function(x) {
  if (!is_vector(x) || is_empty(x)) {
    return(FALSE)
  }

  url_pattern <-
    "http[s]?://(?:[[:alnum:]]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"

  grepl(url_pattern, x)
}

#' Convert a sf object to a data frame of coordinates
#'
#' @noRd
#' @importFrom purrr list_cbind
convert_to_coords <- function(data,
                              coords = c("lon", "lat"),
                              keep_all = TRUE,
                              arg = caller_arg(data),
                              call = caller_env()) {
  check_installed("sf", call = call)

  if (!all(sf::st_is(data, "POINT"))) {
    geom_type <- unique(sf::st_geometry_type(data))

    message <- paste0(
      "`", arg, "` must use POINT geometry only, not ",
      paste0(geom_type, collapse = ", "), "."
    )

    abort(
      message,
      call = call
    )
  }

  stopifnot(
    is.character(coords),
    has_length(coords, 2)
  )

  coords_data <- data |>
    sf::st_transform(4326) |>
    sf::st_coordinates() |>
    as.data.frame() |>
    set_names(coords)

  if (!keep_all || inherits(data, "sfc")) {
    return(coords_data)
  }

  purrr::list_cbind(
    list(
      sf::st_drop_geometry(data),
      coords_data
    )
  )
}

