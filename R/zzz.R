.onAttach <- function(libname, pkgname) {
  stage <- "production"
  packageStartupMessage(paste0("Loading sedtR - using the ", stage, " API"))
}

#' @noRd
sedt_url <- function(
    ...,
    base_url = "https://equity-tool-api.urban.org/api/v",
    version = 1,
    .envir = parent.frame()
) {
  paste0(base_url, version, "/", stringr::str_glue(..., .envir = .envir))
}
