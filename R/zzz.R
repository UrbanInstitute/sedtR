.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Loading sedtR - using the production API")
}

sedt_url <- function(
    base_url = "https://equity-tool-api.urban.org/api/v",
    version = 1,
    ...
) {
  paste0(base_url, version, "/", stringr::str_glue(...))
}
