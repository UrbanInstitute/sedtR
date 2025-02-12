.onAttach <- function(libname, pkgname) {
  stage <- "staging"

  #Determine base URL depending on staging and production
  if (stage == "production") {
    base_url <- "https://equity-tool-api.urban.org/api/v"

  } else {
    # Read the secrets.json file
    secrets <- jsonlite::fromJSON("secrets.json")
    base_url <- secrets$staging_url
  }

  assign("stage", stage, envir=as.environment("package:sedtR"))
  assign("base_url", base_url, envir=as.environment("package:sedtR"))
}

#' @noRd
sedt_url <- function(
    ...,
    version = 1,
    .envir = parent.frame()) {
  base_url <- get("base_url", envir = as.environment("package:sedtR"))
  paste0(base_url, version, "/", stringr::str_glue(..., .envir = .envir))

  }
