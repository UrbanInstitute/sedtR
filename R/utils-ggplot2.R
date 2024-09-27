#' @noRd
GeomLollipop <- ggplot2::ggproto("GeomLollipop", Geom,

                        required_aes = c("x", "y"),

                        default_aes = ggplot2::aes(
                          xend = 0,
                          colour = "black",
                          linewidth = .5,
                          size = 1,
                          linetype = 1,
                          shape = 19,
                          fill = NA,
                          alpha = NA,
                          stroke = 1
                        ),

                        draw_panel = function(data, panel_params, coord, ...) {
                          # Return all three components
                          grid::gList(
                            GeomSegment$draw_panel(data, panel_params, coord, ...),
                            GeomPoint$draw_panel(transform(data), panel_params, coord, ...)
                          )
                        }
)

#' @noRd
geom_lollipop <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          ..., na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    geom = GeomLollipop,
    stat = stat,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

# https://github.com/aphalo/ggpmisc
#' @noRd
symmetric_limits <- function (x) {
  max <- max(abs(x))
  c(-max, max)
}
