.onLoad <- function(libname, pkgname){

  assign("stage", "production", envir = parent.env(environment()))
  assign("base_url",
         "https://equity-tool-api.urban.org",
         envir = parent.env(environment()))

  msg <- paste("Loading", pkgname, " - using ", stage, " API")
  cat(msg)
}
