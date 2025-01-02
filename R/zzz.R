.onAttach <- function(libname, pkgname) {
  stage <- "production"
  assign("stage", stage, envir=as.environment("package:sedtR"))
}

#' @noRd
sedt_url <- function(
    ...,
    base_url = "https://equity-tool-api.urban.org/api/v",
    version = 1,
    .envir = parent.frame()) {
  paste0(base_url, version, "/", stringr::str_glue(..., .envir = .envir))
}

