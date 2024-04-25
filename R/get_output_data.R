#' Function to call get-equity-file api endpoint
#' @param file_id (string) - the id associated with the api function call. This
#' should be returned from call_upload_user_files.R
#' @return list of seven elements:
#'  status_code (integer) - a status code showing whether the API call was successful
#'  file_exists (Boolean) - whether or not the equity status data exists.
#'  file_id (string) - the inputed file_id
#'  geo_bias_data (sf dataframe) - the geographic bias dataset outputted from
#'    SEDT API. NA if file_exists is FALSE.
#'  demo_bias_data (dataframe) - the demographic bias dataset outputted from the
#'    SEDT API. NA if file_exists is FALSE.
#'  download_links - (named list) - composed of three entries geo_bias_geojson,
#'    geo_bias_csv, and demographic_bias_csv. Each of these names maps to a
#'    signed URL where you can download the resulting files from AWS S3. This
#'    serves as an alternative to parsing JSON objects from full_api_results
#'  full_api_results (list) - the entirety of the JSON response object from the
#'    get-equity-file api endpoint converted to an R list. NA if file_exists is FALSE.
#' @export


get_output_data <- function(
  file_id
) {

  output_data_url <- sedt_url("get-output-data/{file_id}/")

  response <- httr::GET(
    url = output_data_url
  )
  status_code <- response[["status_code"]]
  r_json <-  httr::content(response, as = "text", encoding = "UTF-8")
  r_list <- rjson::fromJSON(r_json)
  file_exists <- r_list[["results"]][["file_exists"]]

  #Ensure file exists and is correct:
  file_id_from_data <- r_list[["results"]][["fileid"]]

  stopifnot(identical(file_id_from_data, file_id))

  if (file_exists) {
    geo <- r_list[["results"]][["result"]][["geo_bias_data"]] |> #access geo bias data from list
      rjson::toJSON() |> #convert back to JSON for geojsonsf to read
      geojsonsf::geojson_sf() #Convert from json format to sf dataframe

    demo <- r_list[["results"]][["result"]][["demographic_bias_data"]] |>
      rjson::toJSON() |>
      jsonlite::fromJSON() |>
      as.data.frame()

    download_links <- r_list[["results"]][["result"]][["download_links"]] |>
      rjson::toJSON() |>
      jsonlite::fromJSON() |>
      as.data.frame()


    return(
      list(
        status_code = status_code,
        file_exists = file_exists,
        file_id = file_id,
        geo_bias_data = geo,
        demo_bias_data = demo,
        download_links = download_links
      )
    )
  } else {
    return(
      list(
        status_code = status_code,
        file_exists = file_exists,
        file_id = file_id,
        geo_bias_data = NA,
        demo_bias_data = NA,
        download_links = NA
      )
    )
  }



}
