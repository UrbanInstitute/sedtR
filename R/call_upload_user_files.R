#' Function to call SEDT API /upload-user-files/ endpoint and trigger start
#' of process to conduct SEDT analysis
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

call_upload_user_files <- function(
  resource_file_path,
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
  acs_data_year = "2021"
  ) {

  #Define api URL
  api_url <- stringr::str_glue("{base_url}/api/v1/upload-user-file/")

  #Data Input Type Checks:
  stopifnot(is.character(c(resource_file_path,
                           resource_lat_column,
                           resource_lon_column,
                           geo,
                           acs_data_year)
                         )
  )

  stopifnot(acs_data_year %in%  c("2019", "2021", "2022"))
  stopifnot(geo %in% c("city", "county", "state", "national"))

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
    } else if(!is.na(possible_vars[[i]])) {
      # set name of item in named list to variable name and value to variable value
      payload[names(possible_vars)[[i]]] <- possible_vars[[i]]
    }
  }

  #print(payload)

  response <-
    httr::POST(
      url = api_url,
      body = payload,
      type = "form"
      )

  # parses response and checks for non-201 http code and returns message if so, or file id if got 201
  if (response$status_code == 201) {
    r_json <- httr::content(response, as = "text")
    r_list <- rjson::fromJSON(r_json)
    file_id <- r_list$file_id

    return(list(status_code = response$status_code, file_id = file_id))
  } else{
    # update to parse error message
    r_json <- httr::content(response, as = "text")

    #Check if there Cloudflare blocks data from hitting the API
    if (r_json == "<html>\r\n<head><title>413 Request Entity Too Large</title></head>\r\n<body>\r\n<center><h1>413 Request Entity Too Large</h1></center>\r\n<hr><center>cloudflare</center>\r\n</body>\r\n</html>\r\n") {
      response_to_return <- list(status_code = 413,
                                 error_message = "Request Entity Too Large")
      return(response_to_return)

    } else {
      error_text <- rjson::fromJSON(r_json)
      return(list(status_code = response$status_code, error_message = error_text))

    }


  }
}
