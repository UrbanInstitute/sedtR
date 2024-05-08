#' Function to create a choropleth map to visualize the geographic disparity scores
#'
#' @param geo_df  (sf dataframe) - a spatial dataframe containing the geographic
#' disparity scores outputted from the Spatial Equity Data Tool.
#' @param col_to_plot (string) - The column in the geo_df to plot in
#' choropleth map.
#' @param save_map (logical) - Default set to FALSE. Whether to save the chart
#' or not. Note that if interactive is set to true, the map will save as a
#' .html. Otherwise, the map will save as a .png.
#' @param interactive (logical) - Default set to TRUE. Whether the map should
#' be interactive or not.
#' @param file_path (character) - Default set to "bias_map". A file path of where
#' to save the file. This should not include a file type as that is controlled
#' by the interactive variable. An example file-path would be,
#' "visuals/interactives/disparity_map".
#' @return bias_map (tmap map) - the choropleth map created
#' @export
#' @details
#' Please use the following citation for data obtained from the API,
#' replacing the version number with the current version:
#'
#' Stern, Alena, Gabe Morrison, Sonia Torres Rodríguez, Ajjit Narayanan, and Graham MacDonald. 2024.
#' “Spatial Equity Data Tool API” (Version X.x.x). Washington, DC: Urban Institute.
#' https://ui-research.github.io/sedt_documentation/. Data originally sourced from various sources,
#' analyzed at the Urban Institute and made available under the ODC Attribution License.

create_map <- function(geo_df,
                       col_to_plot = "diff_pop",
                       save_map = FALSE,
                       interactive = TRUE,
                       file_path = "bias_map"

                       ){

  rlang::check_installed(
    c("tmap", "dplyr", "janitor", "urbnthemes"),
    reason = "to use the `create_map()` function. If urbnthemes not installed, we use RdBu color palette"
    )

  # Choose color palette:
  if (rlang::is_installed("urbnthemes")) {
    pal <- urbnthemes::palette_urbn_diverging
  } else {
    pal <- "RdBu"
  }


  #Check all Inputs for correct types:
  stopifnot("sf" %in% class(geo_df))
  stopifnot(is.logical(save_map))
  stopifnot(is.logical(interactive))
  stopifnot(is.character(file_path))

  #Check that col_to_plot is a column in the geo_df
  stopifnot(col_to_plot %in% colnames(geo_df))


  tryCatch(
    #TRY:
    {
      #Set file suffix for saving the chart and set tmap to interactive if
      # interactive is true
      file_suffix = ".png"
      if(interactive){
        tmap::tmap_mode("view")
        file_suffix = ".html"
      } else{
        tmap::tmap_mode("plot")
        file_suffix = ".png"
      }

      # replace observations that are not significantly different with NA
      # multiply by 100 to convert to percentage
      geo_df <- geo_df |>
        dplyr::mutate(!!rlang::sym(col_to_plot) :=
                 dplyr::if_else(!!rlang::sym(stringr::str_glue("sig_{col_to_plot}")) == "FALSE",
                         NA_real_,
                         !!rlang::sym(col_to_plot)*100
                         )
               )

      # Avoid possible errors by ensuring geometry is valid
      valid_geo_df <- sf::st_make_valid(geo_df)

      # Remove empty units to avoid warning. This is caused by tracts that do not have
      # an associated geometry.
      valid_geo_df <- valid_geo_df[!st_is_empty(valid_geo_df),]

      bias_map <-
        tmap::tm_basemap("CartoDB.PositronNoLabels") +
        tmap::tm_shape(valid_geo_df) +
        tmap::tm_fill(col = col_to_plot,
                palette = pal,
                midpoint = 0,
                legend.show = TRUE,
                id = "id_col",
                title = "Disparity Score",
                textNA = "Not Stat. Sig.",
                legend.format= list(
                  fun=function(x) paste0(formatC(x, digits=1, format="f"), " %")
                  )
                ) +
        tmap::tm_borders(lwd = .25) +
        tmap::tm_tiles("CartoDB.PositronOnlyLabels") +
        tmap::tm_layout(legend.outside = TRUE,
                  attr.outside = TRUE,
                  title = janitor::make_clean_names(string = col_to_plot, case = "title")
                  )

      if(save_map){
        tmap::tmap_save(tm = bias_map,
                  filename = stringr::str_c(file_path, file_suffix))
      }
      return(bias_map)
    },
    #CATCH ERROR:
    error = function(e){
      message("An Error Occurred")
      print(e)
    },
    #HANDLE WARNING:
    warning = function(w){
      message("A Warning Occured")
      print(w)
      return(NA)
    }

  )

}

