#' Create a chloropleth map to visualize the geographic disparity scores
#'
#' [create_map()] uses `{tmap}` and `{urbnthemes}` to create a chloropleth map
#' to visualize the geographic disparity scores returned with the response
#' object from [call_sedt_api()].
#'
#' @param geo_df  (sf dataframe) - a spatial dataframe containing the geographic
#' disparity scores outputted from the Spatial Equity Data Tool.
#' @param col_to_plot (string) - The column in the geo_df to plot in
#' choropleth map.
#' @param pkg (string) Package to use when creating the map. One of "tmap"
#'   (default) or "ggplot2".
#' @param interactive (logical) - Default set to TRUE. Whether the map should be
#'   interactive or not.
#' @param save_map (logical) - Default set to FALSE. Whether to save the chart
#'   or not. Note that if `interactive = TRUE` and `pkg = "tmap"`, the map will
#'   save as a .html. Otherwise, the map will save as a .png.
#' @param file_path (character) - Default set to "bias_map". A file path of where
#' to save the file. This should not include a file type as that is controlled
#' by the interactive variable. An example file-path would be,
#' "visuals/interactives/disparity_map".
#' @return bias_map (tmap map or ggplot2 plot) - the choropleth map created
#' @inherit setd-citation details
#' @export
create_map <- function(geo_df,
                       col_to_plot = "diff_pop",
                       ...,
                       pkg = "tmap",
                       interactive = TRUE,
                       save_map = FALSE,
                       save_args = list(),
                       file_path = "bias_map",
                       file_ext = "png") {
  check_installed(
    c("dplyr"),
    reason = "to use the `create_map()` function. If urbnthemes not installed, we use RdBu color palette."
  )

  # Choose color palette:
  if (rlang::is_installed("urbnthemes")) {
    pal <- urbnthemes::palette_urbn_diverging
  } else {
    pal <- "RdBu"
  }

  # Check all Inputs for correct types:
  stopifnot("sf" %in% class(geo_df))
  stopifnot(is.logical(save_map))
  stopifnot(is.logical(interactive))
  stopifnot(is.character(file_path))

  # Check that col_to_plot is a column in the geo_df
  stopifnot(col_to_plot %in% colnames(geo_df))

  tryCatch(
    # TRY:
    {
      # Set file suffix for saving the chart and set tmap to interactive if
      # interactive is true
      if (interactive && pkg == "tmap") {
        file_ext <- "html"
      }

      pkg <- arg_match0(pkg, c("tmap", "ggplot2"))

      if (pkg == "tmap") {
        bias_map <- tm_plot_geo_bias_map(
          data = geo_df,
          fill_col = col_to_plot,
          fill_palette = pal,
          ...
        )
      } else {
        bias_map <- plot_geo_bias_map(
          data = geo_df,
          fill_col = col_to_plot,
          fill_palette = pal,
          ...
        )
      }

      if (save_map) {
        filename <- stringr::str_c(file_path, ".", file_ext)

        if (pkg == "tmap") {
          tmap::tmap_save(
            tm = bias_map,
            filename = filename,
            !!!save_args
          )
        } else {
          ggplot2::ggsave(
            plot = bias_map,
            filename = filename,
            !!!save_args
          )
        }
      }

      return(bias_map)
    },
    # CATCH ERROR:
    error = function(e) {
      message("An Error Occurred")
      print(e)
    },
    # HANDLE WARNING:
    warning = function(w) {
      message("A Warning Occured")
      print(w)
      return(NA)
    }
  )
}

#' Plot a map of geo bias data with `{tmap}` or `{ggplot2}`
#'
#' @param fill_col String with column name to map to fill.
#' @param fill_label Label to use for fill column. Passed as title for
#'   [tmap::tm_fill()] or fill label for [ggplot2::labs()].
#' @param fill_palette String with palette name.
#' @name geo_bias_map
NULL

#' [tm_plot_geo_bias_map()] uses [tmap::tm_shape()] and [tmap::tm_fill()] to map
#' the geo bias data returned by [call_sedt_api()].
#' @inheritParams tmap::tm_layout
#' @keywords internal
tm_plot_geo_bias_map <- function(
    data,
    fill_col = "diff_pop",
    fill_label = "Disparity Score",
    basemap_server = "CartoDB.PositronNoLabels",
    border_lwd = 0.25,
    fill_palette = "RdBu",
    title = NULL,
    legend.outside = TRUE,
    attr.outside = TRUE,
    interactive = FALSE,
    ...) {
  check_installed(c("tmap", "janitor"))

  if (interactive) {
    tmap::tmap_mode("view")
  } else {
    tmap::tmap_mode("plot")
  }

  data <- data |>
    fmt_col_to_plot() |>
    prep_geo_df()

  bias_map <- tmap::tm_basemap(
    server = basemap_server
  ) +
    tmap::tm_shape(data) +
    tmap::tm_fill(
      col = fill_col,
      palette = fill_palette,
      midpoint = 0,
      legend.show = TRUE,
      id = "id_col",
      title = fill_label,
      textNA = "Not Stat. Sig.",
      legend.format = list(
        fun = function(x) {
          paste0(
            formatC(x, digits = 1, format = "f"),
            " %"
          )
        }
      )
    ) +
    tmap::tm_borders(
      lwd = border_lwd
    ) +
    tmap::tm_tiles(
      server = basemap_server
    ) +
    tmap::tm_layout(
      legend.outside = legend.outside,
      attr.outside = attr.outside,
      title = title %||% str_to_label(
        string = fill_col,
        case = "title"
      )
    )

  bias_map
}


#' [plot_geo_bias_map()] uses [ggplot2::geom_sf()] to map the geo bias data
#' returned by [call_sedt_api()].
#' @rdname geo_bias_map
#' @param fill_scale ggplot2 scale function to use with map.
#' @param plot_theme ggplot2 theme to use with map.
#' @keywords internal
plot_geo_bias_map <- function(
    data,
    fill_col = "diff_pop",
    fill_label = "Disparity Score",
    fill_palette = "RdBu",
    fill_scale = ggplot2::scale_fill_distiller(
      type = "div",
      palette = fill_palette,
      labels = scales::label_percent(scale = 1),
      direction = 1
    ),
    plot_theme = ggplot2::theme_void()) {
  geo_df <- data |>
    fmt_col_to_plot(
      col_to_plot = fill_col
    ) |>
    prep_geo_df()

  check_installed("ggplot2")

  ggplot2::ggplot(data = geo_df) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = .data[[fill_col]]),
      color = "white"
    ) +
    fill_scale +
    plot_theme +
    ggplot2::labs(
      fill = fill_label
    )
}

#' Format column to plot on map
#' @noRd
fmt_col_to_plot <- function(data, col_to_plot = "diff_pop") {
  check_installed("dplyr")

  data |>
    dplyr::mutate(
      !!sym(col_to_plot) := dplyr::if_else(
        # Replace observations that are not significantly different with NA
        !!sym(stringr::str_glue("sig_{col_to_plot}")) == "FALSE",
        NA_real_,
        # Otherwise multiply by 100 to convert to percentage
        !!sym(col_to_plot) * 100
      )
    )
}

#' Prep a sf data frame by ensuring valid geometry and dropping empty geometry
#' @noRd
prep_geo_df <- function(data) {
  check_installed("dplyr")

  data |>
    # Ensure geometry is valid to avoid possible errors
    sf::st_make_valid() |>
    dplyr::filter(
      # Remove empty units to avoid warning from tracts with no associated
      # geometry.
      !sf::st_is_empty(.data[[attr(data, "sf_column")]])
    )
}
