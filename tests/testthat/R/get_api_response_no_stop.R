#' Get API Response
#'
#' Calls call_upload_user_files() for a given file path, lat col,
#' and lon col, parses and returns API response
#'
#' IMPORTANT NOTE This function avoids checks in R/get_api_response
#'  by calling call_upload_user_files_no_stop().
#'  It should be used for testing the API operates as expected
#'  and not to call the API for SEDT analysis.
#'
#' @param file_path (string) path to resource file
#' @param lat_col
#' @param lon_col
#'
#' @return
#' @export
#'
#' @examples
get_api_response_no_stop <- function(param_list){

  r <- call_upload_user_files_no_stop(
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
