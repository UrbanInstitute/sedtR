#' @noRd
GeomLollipop <- ggplot2::ggproto("GeomLollipop", ggplot2::Geom,

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
                          # Return both the line and point components
                          grid::gList(
                            ggplot2::GeomSegment$draw_panel(data, panel_params, coord, ...),
                            ggplot2::GeomPoint$draw_panel(transform(data), panel_params, coord, ...)
                          )
                        }
)

#' @noRd
geom_lollipop <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          ..., na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE) {
  ggplot2::layer(
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
#'
#' @noRd
GeomBarbell <- ggplot2::ggproto("GeomBarbell", ggplot2::Geom,

                                 required_aes = c("x", "y", "xend|yend"),

                                 default_aes = ggplot2::aes(
                                   xend = 0,
                                   yend = 0,
                                   colour = "black",
                                   # linewidth = ggplot2::from_theme(linewidth),
                                   size = 1,
                                   linetype = 1,
                                   shape = 19,
                                   fill = NA,
                                   alpha = NA,
                                   stroke = 1
                                 ),

                                 draw_panel = function(data, panel_params, coord, ...) {
                                   # Transformed data for the points
                                   point1 <- transform(data)
                                   point2 <- transform(data, x = xend, y = yend)

                                   # Return all three components
                                   grid::gList(
                                     ggplot2::GeomSegment$draw_panel(data, panel_params, coord, ...),
                                     ggplot2::GeomPoint$draw_panel(point1, panel_params, coord, ...),
                                     ggplot2::GeomPoint$draw_panel(point2, panel_params, coord, ...)
                                   )
                                 }
)

#' @noRd
geom_barbell <- function(mapping = NULL, data = NULL,
                         stat = "identity", position = "identity",
                         ..., na.rm = FALSE, show.legend = NA,
                         inherit.aes = TRUE) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    geom = GeomBarbell,
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
