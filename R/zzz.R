.onLoad <- function(libname, pkgname){

  assign("stage", "staging", envir = parent.env(environment()))
  assign("base_url",
         "https://equity-tool-api-stg.urban.org",
         envir = parent.env(environment()))
  assign("s3_bucket",
         "ui-sedt-stg",
         envir = parent.env(environment()))

  msg <- paste("Loading", pkgname, " - using ", stage, " API")
  cat(msg)
}
