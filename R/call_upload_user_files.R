#' @noRd
check_resource_file_path <- function(
    file,
    coords = c("lon", "lat"),
    arg = caller_arg(file),
    call = caller_env()) {

  if (!(is_string(file) && file.exists(file))) {
    abort(
      "{.arg {arg}} must be a valid path to an existing file.",
      call = call
    )
  }

  if (!(is.character(coords) && has_length(coords, 2))) {
    abort(
      "Valid latitude and longitude column names must be supplied.",
      call = call
    )
  }

  invisible(NULL)
}

#' @noRd
match_acs_data_year <- function(acs_data_year,
                                error_call = caller_env()) {
  acs_data_year <- as.character(acs_data_year)

  arg_match0(
    acs_data_year,
    c("2019", "2021", "2022"),
    error_call = error_call
  )
}

#' @noRd
match_geo <- function(geo,
                      error_call = caller_env()) {
  arg_match0(
    geo,
    c("city", "county", "state", "national"),
    error_call = error_call
  )
}

#`' @noRd
check_distance_mode <- function(distance_mode,
                                error_call = caller_env()) {
  arg_match0(
    distance_mode,
    c("drive", "walk"),
    error_call = error_call
  )
}

check_distance_time <- function(distance_mode,
                               distance_time,
                               error_call = caller_env()) {

  if (!is.numeric(distance_time)){
    abort(
      "Distance time must be a numeric value.",
      call = error_call
    )
  }

  valid_walk_times <- c(10, 15, 20)
  valid_drive_times <- c(15, 30, 60)

  if (distance_mode == "walk") {
    if (!(distance_time %in% valid_walk_times)) {
      abort(
        "Valid walk times are 10, 15, and 20 minutes.",
        call = error_call
      )
    }
  }

  if (distance_mode == "drive") {
    if(!(distance_time %in% valid_drive_times)) {
      abort(
        "Valid drive times are 15, 30, and 60 minutes.",
        call = error_call
      )
    }
  }
  return(distance_time)
}

na_to_empty <- function(x) {
  if (is.na(x)) "" else x
}

#' Call the SEDT API and return an API response
#'
#' [call_upload_user_files()] calls the SEDT API /upload-user-files/ endpoint
#' and trigger start of process to conduct SEDT analysis. This is a helper
#' function that is used by [call_sedt_api()] and is primarily internded for
#' internal use.
#'
#' @inheritParams prep_sedt_resource
#' @param resource_file_path (string) Default `NULL`. File path to location
#'   where the resource file dataset is stored. Dataset should be a csv or tsv.
#'   Optional if `resource` is provided.
#' @param resource_lat_column (string) Default "lat". a column name in in the
#'   resource_file dataset indicating the resource latitude column.
#' @param resource_lon_column (string) Default "lon". a column name in in the
#'   resource_file dataset indicating the resource longitude column
#' @param demographic_file_path (string) Optional: a path to the location where
#'   the demographic supplemental dataset is stored. Dataset should be a csv or
#'   tsv.
#' @param demographic_geo_id_column (string) Only necessary if a demographic
#'  file is provided. The name of the column with FIPS codes identifying the
#'  geography
#' @param demographic_columns (string representation of Python dictionary) Only
#'  necessary if a demographic file is provided. Data should be of the form
#'  "{'key':'value'}" where keys are the names of variable columns and value
#'  are either the name of their respective standard error columns or NA if the
#'  column lacks standard errors.
#' @param geographic_file_path (string) Optional: a path to the location where
#'   the supplemental geographic dataset is stored. Dataset should be either csv
#'   or tsv.
#' @param geographic_geo_id_column (string): Required if there is a geographic
#'   dataset provided. The name of the column with FIPS codes identifying the
#'   geography
#' @param geographic_columns (string representation of Python dictionary) Only
#'  necessary if a geographic file is provided. Data should be of the form
#'  "{'key':'value'}" where keys are the names of variable columns and values
#'  are either the names of their respective standard error columns or NA if the
#'  column lacks standard error data.
#' @param resource_filters (string representation of Python list of
#'   dictionaries).
#'  Optional. Each dictionary has the structure {"filter_column":"\[Column Name\]",
#'  "filter_comparison" : "\[Comparison Operator\]", "filter_type":"\[type\]",
#'  "filter_val":"\[filter value\]"}. The filter-column key should be paired with
#'   a column name in the resource dataset. The filter_comparison operator
#'   should be one of the following: "==", ">=", "<=", "<", ">", "!=", or
#'   "dateRange". The filter type should be one of "string", "number" or "date."
#'   filter_val depends on the type. More broadly, the parameter allows users to
#'   input numeric-, string-, or date-based filters. For numeric filters, the
#'   filter_column should be numeric, the filter_comparison can be any of the
#'   listed alternatives except "dateRange", and the value should be a number
#'   wrapped in a string (ex.: "1"). For string filters, the filter_column
#'   should contain strings, the filter_comparison should be either "==" or
#'   "!=", and the filter_val should be a string. For date-based filters, the
#'   filter_column should contain dates, the filter_comparison should be
#'   dateRange, and the filter_val should be of the form "date1-date2".
#' @param resource_weight (string): Optional. Should be the name of a column in
#'   the resource dataset. If included, the number of resources in a geography
#'   will be weighted using this column. Can't be used if resource is a `sfc`
#'   object.
#' @param geo (string): One of "city", "county", "state", or "country".
#'   Indicates the geographic level at which the analysis should be conducted.
#' @param acs_data_year (string or integer): The tool currently has 2019 and
#'   2021 data in it. A four digit year beginning with "20" must be inputted. If
#'   it is different than "2019" or "2021" the tool will use 2021 data. A
#'   default value can be set using the "sedtR.year" option.
#' @param distance_mode (string): Optional. One of "walk" or "drive"
#' @param distance_time (integer): Optional. If distance_mode is walk, one of
#'  10, 15, 20. If mode is drive, one of 15, 30, 60. If a string is provided,
#'  we parse to integer.
#' @param ... Additional parameters passed to [arcgislayers::arc_read()] or
#'   [sf::st_read()] depending on the value provided to `resource`.
#' @return response (list): The function wraps [httr::POST()] which returns a
#'   "response object" which is a list with information about the request. See
#'   the [API documentation](https://ui-research.github.io/sedt_documentation/)
#'   for more details.
#' @inherit prep_sedt_resource details
#' @keywords internal
#' @export
call_upload_user_files <- function(
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
  distance_mode = NA,
  distance_time = NA,
  ...,
  call = caller_env()
) {
  # Define api URL
  api_url <- sedt_url("upload-user-file/")

  resource_file_path <- resource_file_path %||% prep_sedt_resource(
    resource = resource,
    coords = c(resource_lon_column, resource_lat_column),
    ...,
    call = call
  )

  check_resource_file_path(
    resource_file_path,
    coords = c(resource_lon_column, resource_lat_column),
    call = call
  )

  acs_data_year <- match_acs_data_year(acs_data_year, error_call = call)

  geo <- match_geo(geo, error_call = call)

  #Checks for distance measure:
  #stopifnot(is.numeric(distance_time))

  # Ensure mode is allowed
  if(!is.na(distance_mode)) {
    distance_mode <- check_distance_mode(distance_mode, error_call = call)
  }

  # Ensure time is allowed
  if (!is.na(distance_time)) {
    distance_time <- check_distance_time(distance_mode,
                                         distance_time,
                                         error_call = call)
  }

  # stop for state and national calls:
  if (geo %in% c("state", "national") & !is.na(distance_mode)) {
    stop("State and national calls are not supported for this distance access")
  }

  # Ensure both distance_mode and distance_time are provided if one is provided
  if (is.na(distance_mode) & !is.na(distance_time)) {
    stop("If distance_time is provided, distance_mode must also be provided")
  }
  if (!is.na(distance_mode) & is.na(distance_time)) {
    stop("If distance_mode is provided, distance_time must also be provided")
  }

  # Message about beta:
  if (!is.na(distance_mode)) {
    message("Please note that all analyses using travel shed functionality are in beta mode.")
  }

  # Create json for distance access
  if (!is.na(distance_mode)) {
    distance_access_list <- list()
    distance_access_list[distance_mode] <- distance_time
    distance_access_json <- rjson::toJSON(distance_access_list)
  } else {
    distance_access_json <- NA
  }


  possible_vars <- list(demographic_file_path = demographic_file_path,
                        demographic_geo_id_column = demographic_geo_id_column,
                        demographic_columns = demographic_columns,
                        geographic_file_path = geographic_file_path,
                        geographic_geo_id_column = geographic_geo_id_column,
                        geographic_columns = geographic_columns,
                        resource_filters = resource_filters,
                        resource_weight = resource_weight)

  # print("Possible vars are: ")
  # print(possible_vars)
  #
  # print("________________________________")

  # iterate over list to handle case of geographic and demographic columns
  # condition is met if all of the values are NA or character

  for (i in seq_along(possible_vars)) {

    possible_vars[[i]] <- convert_to_na(possible_vars[[i]])
    if(names(possible_vars)[[i]] %in% c("demographic_columns", "geographic_columns")) {
      if(is.list(possible_vars[[i]])) {

        # convert possible valid entries for NA to NA
        for (c in seq_along(possible_vars[[i]])) {
          possible_vars[[i]][[c]] = convert_to_na(possible_vars[[i]][[c]])
        }

        stopifnot(all(sapply(possible_vars[[i]], is_valid_col_type)))
      }
    } else if (names(possible_vars)[[i]] == "resource_filters") {
      if(!is.list(possible_vars[[i]])) {
        stopifnot(all(sapply(possible_vars[[i]], is.na)))
      } else {
        stopifnot(all(sapply(possible_vars[[i]], is.list)))
      }
    } else if(!all(sapply(possible_vars[[i]], is.na))) {
      stopifnot(all(sapply(possible_vars[[i]], is.character)))
    }
  }

  #Upload all files as necessary
  resource_file <- httr::upload_file(resource_file_path)


  if(!(is.na(possible_vars$demographic_file_path))) {
    demographic_file <- httr::upload_file(demographic_file_path)
    possible_vars[["demographic_file"]] = list(demographic_file)
  }

  if(!(is.na(possible_vars$geographic_file_path))) {
    geographic_file <- httr::upload_file(geographic_file_path)
    possible_vars[["geographic_file"]] = list(geographic_file)
  }

  #Generate payload list to send in POST request:
  payload <- list(
    "resource_file" = resource_file,
    "resource_lat_column" = resource_lat_column,
    "resource_lon_column" = resource_lon_column,
    "geo" = geo,
    "acs_data_year" = acs_data_year
  )

  for (i in seq_along(possible_vars)) {
    if(names(possible_vars)[[i]] %in% c("demographic_columns", "geographic_columns")) {
      if(is.list(possible_vars[[i]])){
        # set name of item in named list to variable name and value to variable value
        payload[names(possible_vars)[[i]]] = jsonlite::toJSON(possible_vars[[i]],
                                                              na = "null",
                                                              null = "null",
                                                              auto_unbox = TRUE)
      }
    } else if (names(possible_vars)[[i]] == "resource_filters") {
      if(is.list(possible_vars[[i]]) && length(possible_vars[[i]]) > 0) {
        # convert entries in resource_filters list to JSON
        filter_list <- purrr::map(possible_vars[[i]],
                                   ~jsonlite::toJSON(.x,
                                                     na = "null",
                                                     null = "null",
                                                     auto_unbox = TRUE))
        payload[names(possible_vars)[[i]]] <- jsonlite::toJSON(unlist(filter_list))
      } else {
        # if resource_filters is null, create empty list
        payload[names(possible_vars)[[i]]] <- jsonlite::toJSON(list(), na = "null", null = "null")
      }
     }
    else if(!is.na(possible_vars[[i]])) {
      # set name of item in named list to variable name and value to variable value
      payload[names(possible_vars)[[i]]] <- possible_vars[[i]]
    }
    else {
      payload[[names(possible_vars)[[i]]]] <- na_to_empty(possible_vars[[i]])
    }
   }

  ## Add distance access payload:
  if (!is.na(distance_mode)) {
    payload$distance_access <- distance_access_json
    message("adding distance access to payload...")
  } else {
    message("not doing distance_access")
  }

  #print(payload)

  response <-
    httr::POST(
      url = api_url,
      body = payload,
      type = "form"
      )

  message("Getting response...")

  # parses response and checks for non-201 http code and returns message if so, or file id if got 201
  if (response$status_code == 201) {
    r_json <- httr::content(response, as = "text", encoding = "UTF-8")

    r_list <- rjson::fromJSON(r_json)
    file_id <- r_list$file_id

    return(list(status_code = response$status_code, file_id = file_id))
  } else{
    # update to parse error message
    r_json <- httr::content(response, as = "text", encoding = "UTF-8")

    # Check if there Cloudflare blocks data from hitting the API
    if (r_json == "<html>\r\n<head><title>413 Request Entity Too Large</title></head>\r\n<body>\r\n<center><h1>413 Request Entity Too Large</h1></center>\r\n<hr><center>cloudflare</center>\r\n</body>\r\n</html>\r\n") {
      response_to_return <- list(status_code = 413,
                                 error_message = "Request Entity Too Large")
      return(response_to_return)

    } else {
      error_text <- rjson::fromJSON(r_json)

      # if (class(error_text) == "list") {
      #    error_text = rjson::fromJSON(gsub("(?<!\\[)'(?!\\])", "\"", error_text, perl = TRUE))
      #  }

      return(list(status_code = response$status_code, error_message = error_text))

    }


  }
}
