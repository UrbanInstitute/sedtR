#' Title
#'
#' @param file_id (string) id string corresponding to a POST request that was previously submitted to
#' the /upload-user-file endpoint
#'
#' @return r_list (list) An R list of a JSON object with information about the submission to the SEDT
#' @export
get_status <- function(file_id) {


  status_url <- sedt_url("get-output-data-status/{file_id}/")
  response <- httr::GET(url = status_url)

  r_json <- httr::content(response, as = "text")
  r_list <- rjson::fromJSON(r_json)

  return(r_list)

}
