#' Prepare a resource for upload to the Spatial Equity Data Tool API
#'
#' [prep_sedt_resource()] is used by [call_sedt_api()] to convert an object or
#' URL to a valid file path before uploading the file to the Spatial Equity Data
#' Tool API.
#'
#' @param resource A URL, file path, sf or sfc object, or a data frame with
#'   `coords` columns. See details for more information.
#' @param coords A length 2 character vector with coordinate column names in
#'   lon/lat order. Should correspond to the `resource_lon_column` and
#'   `resource_lat_column` values for [call_sedt_api()].
#' @param file File path for output file. Optional. If `NULL`, file path is set
#'   to a temporary directory.
#' @inheritParams rlang::args_error_context
#' @details Valid resource inputs
#'
#' To call the Spatial Equity Data Tool API, [call_sedt_api()] requires a CSV or
#' TSV input file with coordinate attribute columns. [prep_sedt_resource()] also allows users to alternatively supply:
#'
#' - A URL for a delimited file with coordinate columns or a spatial data file
#' - A ArcGIS FeatureLayer or Table URL (read with [arcgislayers::arc_read()])
#' - A file path for a spatial or tabular data file that can be read with [sf::read_sf()]
#' - A data frame containing the named columns in `coords`
#' - A `sf` or `sfc` object with POINT geometry that can be converted to a data frame using [sf::st_coordinates()]
#'
#' If resource is an `sf` object or a path to a spatial data file with POLYGON,
#' MULTIPOLYGON, or any non-POINT geometry, `placement` is used to convert the
#' input into points. [sf::st_centroid()] (if `placement = "centroid"`) or
#' [sf::st_point_on_surface()] (if `placement = "surface"` which is the default)
#' option.
#' @returns A path to a CSV or TSV file (depending on value of `fileext`).
#' @keywords internal
#' @export
#' @importFrom utils write.csv
#' @importFrom curl multi_download
prep_sedt_resource <- function(resource,
                               coords = c("lon", "lat"),
                               file = NULL,
                               fileext = "csv",
                               ...,
                               arg = caller_arg(resource),
                               call = caller_env()) {
  check_sedt_resource(resource, coords = coords, arg = arg, call = call)

  # If resource is a URL it must be a downloadable file, a FeatureLayer, or Table
  if (is_string(resource) && is_url(resource)) {
    if (grepl("rest/services", resource)) {
      # Download FeatureLayer or Table
      check_installed("arcgislayers", call = call)
      resource <- arcgislayers::arc_read(resource, ..., crs = 4326)
    } else {
      file <- file %||% file.path(tempdir(), basename(resource))
      curl::multi_download(resource, destfiles = file)
      resource <- file
    }
  }

  if (is_string(resource) && file.exists(resource)) {
    # Return an existing delimited file path as is
    if (is_delim_path(resource)) {
      return(resource)
    }

    # If not a delimited file attempt to read other file types with
    # `sf::read_sf`
    check_installed("sf", call = call)
    resource <- sf::read_sf(resource, ...)
  }

  # Convert sf object to data frame
  if (inherits_any(resource, c("sf", "sfc"))) {
    resource <- convert_to_coords(
      resource,
      coords = coords,
      call = call
    )
  }

  file <- file %||% tempfile(fileext = paste0(".", fileext))

  if (is_installed("readr")) {
    readr::write_csv(
      resource,
      file = file
    )
  } else {
    utils::write.csv(
      resource,
      file = file
    )
  }

  file
}

#' @noRd
check_sedt_resource <- function(resource,
                                ...,
                                coords = c("lon", "lat"),
                                allow_null = FALSE,
                                arg = caller_arg(resource),
                                call = caller_env()) {
  if (allow_null && is.null(resource)) {
    return(invisible(NULL))
  }

  not_message <- "not {.obj_type_friendly {resource}}"

  if (is_string(resource)) {
    if (is_url(resource) || file.exists(resource)) {
      return(invisible(NULL))
    }

    not_message <- "not {.str {resource}}"
  } else if (inherits_any(resource, c("sf", "sfc"))) {
    return(invisible(NULL))
  } else if (is.data.frame(resource) && all(has_name(resource, coords))) {
    return(invisible(NULL))
  }

  message <- paste0(
    "{.arg {arg}} must a path to an existing file, a valid url,
    a sf or sfc object, or a data frame with columns named {coords}, ",
    not_message
  )

  cli::cli_abort(
    message,
    call = call
  )
}
