#' Function to visualize demographic disparity scores on a lollipop chart
#' @param demo_df (data.frame) - the demographic disparity score dataframe
#'  returned by the SEDT API
#' @param group (character) - One of "total", "poverty", or "under18". Default
#' is "total" This variable indicates the demographic group for which the chart
#' to show.
#' @param save_chart (logical) - Default set to FALSE. Whether to save the chart
#'  or not.
#' @param file_path (character) - Default set to "dem_disparity_chart.png".
#' A file path of where to save the file. This should include a data type
#' suffix. EX: "results/visuals/dem_disparity_chart.png"
#' @inherit setd-citation details
#' @return plot (ggplot object)  - The ggplot object that was created.
#' @export
create_demo_chart <- function(
    demo_df,
    group = "total",
    ...,
    save_chart = FALSE,
    file_path = "dem_disparity_chart.png",
    pct_abb = "Pct.",
    ggsave_args = list(
      width = 11,
      height = 8.5,
      units = "in"
    )) {
  check_installed(
    c("forcats", "janitor", "scales", "ggplot2", "dplyr"),
    reason = "to use the `create_demo_chart()` function."
  )

  # Data is correct class:
  stopifnot("data.frame" %in% class(demo_df))
  stopifnot(is.logical(save_chart))
  stopifnot(is.character(file_path))
  stopifnot(is.character(group))

  # Other checks:
  stopifnot(TRUE %in% endsWith(
    file_path,
    c(
      "eps", "ps", "tex", "pdf", "jpeg",
      "tiff", "png", "bmp", "svg", "wmf"
    )
  )) # file path is allowed by ggsave

  df <- filter_baseline_group(
    demo_df,
    group = group
  )

  df <- fmt_pos_diff(df)

  # Edit string names
  df <- fmt_census_var_label(df, pct_abb = pct_abb)

  # We get max value before filtering bc the limits of all 3 baseline_pops
  # should be equal for comparability
  max_val <- max(abs(df$diff_data_city)) * 1.1

  demo_lollipop_plot <- plot_demo_lollipop(
    data = df,
    max_val = max_val
  )

  if (save_chart) {
    ggplot2::ggsave(
      filename = file_path,
      plot = demo_lollipop_plot,
      !!!ggsave_args
    )
  }

  demo_lollipop_plot
}

#' Create geom for demographic lollipop plot
#' @noRd
plot_demo_lollipop <- function(data,
                               max_val,
                               ...,
                               labelled = TRUE,
                               plot_annotation = annotation_demo_lollipop(),
                               plot_theme = theme_demo_lollipop()) {
  lollipop_plot <- ggplot2::ggplot(
    data = data,
    mapping = ggplot2::aes(y = census_var, x = diff_data_city)
  )

  lollipop_plot_labels <- list()

  if (labelled) {
    lollipop_plot_labels <- list(
      # Put text to left/right of 0 line to match equity tool
      ggplot2::geom_text(
        data = dplyr::filter(data, diff_data_city >= 0),
        ggplot2::aes(
          x = max(diff_data_city) * -0.06,
          y = census_var,
          label = census_var
        ),
        hjust = "right",
        size = 4
      ),
      ggplot2::geom_text(
        data = dplyr::filter(data, diff_data_city < 0),
        ggplot2::aes(
          x = max(abs(diff_data_city)) * 0.06,
          y = census_var,
          label = census_var
        ),
        hjust = "left",
        size = 4
      )
    )
  }

  lollipop_plot +
    c(
      list(
        ggplot2::geom_vline(
          xintercept = 0,
          color = "#353535"
        ),
        geom_lollipop(
          ggplot2::aes(
            x = diff_data_city,
            y = census_var,
            color = pos_diff
          ),
          size = 3
        ),
        ggplot2::scale_x_continuous(
          position = "top",
          limits = c(-max_val, max_val),
          labels = scales::label_percent(scale = 1)
        ),
        ggplot2::labs(y = "", x = ""),
        scale_color_demo_pos_diff()
      ),
      lollipop_plot_labels,
      plot_annotation,
      plot_theme
    )
}

#' ggplot2 theme for create_demo_chart function
#' @inheritParams ggplot2::theme
#' @param ... Additional parameters passed to [ggplot2::theme()]
#' @noRd
theme_demo_lollipop <- function(
    plot.margin = ggplot2::margin(
      t = 5, r = 10, b = 5, l = 5
    ),
    panel.background = ggplot2::element_rect(
      fill = "white",
      colour = "black"
    ),
    legend.position = "none",
    ...) {
  list(
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      panel.background = panel.background,
      plot.margin = plot.margin,
      legend.position = legend.position,
    ),
    ggplot2::theme(
      ...
    )
  )
}

#' @noRd
demo_text_label <- function(
    label = "Underrepresented",
    x = .02,
    y = 0.02,
    just = c("left", "top"),
    rot = 90,
    font_face = "bold",
    font_color = "#ca5800",
    font_size = 18,
    font_alpha = 0.75,
    ...) {
  grid::textGrob(
    label = label,
    x = x,
    y = y,
    just = just,
    rot = rot,
    gp = grid::gpar(
      fontface = font_face,
      col = font_color,
      fontsize = font_size,
      alpha = font_alpha
    ),
    ...
  )
}

#' Annotations for create_demo_chart function
#' @noRd
annotation_demo_lollipop <- function() {
  # Generate under/overrep labels to use in annotation_custom. This is the only
  # way we can set x and y relatively to full plot window instead of actual
  # axis numbers which vary with the data
  list(
    ggplot2::annotation_custom(
      demo_text_label(
        label = "Underrepresented",
        x = 0.02,
        y = 0.02,
        just = c("left", "top"),
        font_color = "#ca5800"
      ),
      xmin = -Inf,
      xmax = Inf,
      ymin = -Inf,
      ymax = Inf
    ),
    ggplot2::annotation_custom(
      demo_text_label(
        label = "Overrepresented",
        x = 0.96,
        y = 0.98,
        just = c("right", "top"),
        font_color = "#1696d2"
      ),
      xmin = -Inf,
      xmax = Inf,
      ymin = -Inf,
      ymax = Inf
    )
  )
}

#' Scale color based on pos_diff column derived by `fmt_diff_data_city()`
#' @noRd
scale_color_demo_pos_diff <- function(
    values = c(
      "positive" = "#1696d2",
      "not_stat_sig" = "#7f7f7f",
      "negative" = "#ca5800"
    ),
    ...,
    aesthetics = c("color", "fill")) {
  ggplot2::scale_color_manual(
    values = values,
    aesthetics = aesthetics,
    ...
  )
}

#' Use sig_diff and diff_data_city to derive pos_diff column
#' @noRd
fmt_pos_diff <- function(data) {
  data |>
    dplyr::mutate(
      pos_diff = dplyr::case_when(
        !sig_diff ~ "not_stat_sig",
        diff_data_city > 0 ~ "positive",
        diff_data_city < 0 ~ "negative"
      )
    )
}

#' Shorten census_var column
#' @noRd
fmt_census_var_label <- function(data, pct_abb = "Pct.", call = caller_env()) {
  check_installed(
    c("forcats", "janitor", "dplyr"),
    reason = "to create plots with `create_demo_chart()`",
    call = call
  )

  dplyr::mutate(
    data,
    census_var = str_to_label(census_var, case = "title"),
    census_var = stringr::str_replace_all(census_var, "Pct", pct_abb),
    census_var = stringr::str_replace_all(census_var, "under18", "Under 18"),
    census_var = stringr::str_replace_all(census_var, "Unins", "Uninsured"),
    census_var = stringr::str_replace_all(census_var, "Hisp", "Hispanic"),
    census_var = stringr::str_replace_all(census_var, "under", "Under"),
    census_var = stringr::str_replace_all(census_var, "Unemp$", "Unemployed"),
    census_var = stringr::str_replace_all(census_var, "Cb", "Cost-Burdened"),
    census_var = stringr::str_replace_all(census_var, "Hs ", "HS "),
    census_var = stringr::str_replace_all(census_var, "Hh", "Household"),
    census_var = stringr::str_replace_all(census_var, "Bach", "Bachelors"),
    census_var = stringr::str_replace_all(census_var, "Pov ", "Poverty "),
    census_var = forcats::fct_reorder(census_var, diff_data_city)
  )
}

#' Match baseline group value
#' @noRd
match_baseline_group <- function(group, error_call = caller_env()) {
  arg_match0(group, c("total", "poverty", "under18"), error_call = error_call)
}

#' Filter data to baseline group variable
#' @noRd
filter_baseline_group <- function(
    data,
    group = c("total", "poverty", "under18"),
    call = caller_env()) {
  group <- match_baseline_group(group, error_call = call)

  data |>
    dplyr::filter(
      stringr::str_detect(baseline_pop, group)
    )
}
