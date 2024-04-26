#' Function to visualize demographic disparity scores on a lollipop chart
#' @param demo_df (data.frame) - the demographic disparity score dataframe
#'  returned by the SEDT API
#' @param group (character) - One of "total", "poverty", or "under18". Default
#' is "total" This variable indicates the demographic group for which the chart
#' to show.
#' @param save_chart (logical) - Default set to TRUE. Whether to save the chart
#'  or not.
#' @param file_path (character) - Default set to "dem_disparity_chart.png".
#' A file path of where to save the file. This should include a data type
#' suffix. EX: "results/visuals/dem_disparity_chart.png"
#' @return plot (ggplot object)  - The ggplot object that was created.
#' @export

create_demo_chart <- function(demo_df,
                              group = "total",
                              save_chart = TRUE,
                              file_path = "dem_disparity_chart.png") {

  rlang::check_installed(
    c("forcats", "janitor", "scales", "ggplot2", "dplyr"),
    reason = "to use the `create_demo_chart()` function."
  )

  #Data is correct class:
  stopifnot("data.frame" %in% class(demo_df))
  stopifnot(is.logical(save_chart))
  stopifnot(is.character(file_path))
  stopifnot(is.character(group))

  #Other checks:
  stopifnot(group %in% c("total", "poverty", "under18")) #group is one of provided options
  stopifnot(TRUE %in% endsWith(file_path,
                               c("eps", "ps", "tex", "pdf", "jpeg",
                                 "tiff", "png", "bmp", "svg", "wmf"))
  ) #file path is allowed by ggsave

  tryCatch(
    #TRY:
    {
      #urbnthemes::set_urbn_defaults(style = "print")

      #Handle filtering to one of the baseline groups
      #Note that this will need to be updated to work with API data, but overall
      # logic should be similar
      if(group == "total") {
        df <- demo_df |>
          dplyr::filter(!(stringr::str_detect(census_var, "pct_pov"))) |>
          dplyr::filter(!(stringr::str_detect(census_var, "pct_under18")))
      }else if(group == "poverty"){
        df <- demo_df |>
          dplyr::filter(stringr::str_detect(census_var, "pct_pov"))
      }else{
        df <- demo_df |>
          dplyr::filter(stringr::str_detect(census_var, "pct_under18"))
      }

      #Convert to Percent
      df <- dplyr::mutate(df, diff_data_city = diff_data_city / 100)


      #Edit string names:
      df <- df |>
        dplyr::mutate(census_var = janitor::make_clean_names(census_var, case = "title"),
                      census_var = stringr::str_replace_all(census_var, "Pct", "Pct."),
                      census_var = stringr::str_replace_all(census_var, "under18", "Under 18"),
                      census_var = stringr::str_replace_all(census_var,"Unins", "Uninsured"),
                      census_var = stringr::str_replace_all(census_var, "Hisp", "Hispanic"),
                      census_var = stringr::str_replace_all(census_var, "under", "Under"),
                      census_var = stringr::str_replace_all(census_var, "Unemp", "Unemployed"),
                      census_var = stringr::str_replace_all(census_var, "Cb", "Cost-Burdened"),
                      census_var = stringr::str_replace_all(census_var, "Hh", "Household"),
                      census_var = stringr::str_replace_all(census_var, "Bach", "Bachelors"),
                      census_var = stringr::str_replace_all(census_var, "Pov ", "Poverty ")
        )

      # We get max value before filtering bc the limits of all 3 baseline_pops
      # should be equal for comparability
      max_val = max(abs(df$diff_data_city)) * 1.1

      df_plot <- df |>
        dplyr::mutate(pos_diff = dplyr::if_else(diff_data_city > 0, "positive", "negative"),
                      pos_diff = dplyr::if_else(sig_diff, pos_diff, NA),
                      census_var = forcats::fct_reorder(census_var, diff_data_city)) |>
        dplyr::arrange(dplyr::desc(diff_data_city))


      last_var = df_plot |>
        dplyr::arrange(dplyr::desc(diff_data_city)) |>
        utils::tail(1) |>
        dplyr::pull(census_var) |>
        as.character()
      first_var = df_plot |>
        dplyr::arrange(dplyr::desc(diff_data_city)) |>
        utils::head(1) |>
        dplyr::pull(census_var) |>
        as.character()

      # Generate under/overrep labels to use in annotation_custom. This is the only
      # way we can set x and y relatively to full plot window instead of actual
      # axis numbers which vary with the data
      underrep_label = grid::textGrob(label = "Underrepresented", x = .02, y = 0.02,
                                      just = c("left", "top"),
                                      rot = 90,
                                      gp=grid::gpar(fontface = "bold",
                                                    #fontfamily = "Lato",
                                                    #col = "#eec046",
                                                    #col = urbnthemes::palette_urbn_diverging[7],
                                                    fontsize = 18,
                                                    #alpha = 0.5
                                                    alpha = .75
                                      ))

      overrep_label = grid::textGrob(label = "Overrepresented", x = .96, y = 0.98,
                                     just = c("right", "top"),
                                     rot = 90,
                                     gp=grid::gpar(fontface = "bold",
                                                   #fontfamily = "Lato",
                                                   #col = urbnthemes::palette_urbn_diverging[1],
                                                   fontsize = 18,
                                                   alpha = 0.75))

      plot <-
        df_plot |>
        ggplot2::ggplot(ggplot2::aes(y = census_var, x = diff_data_city)) +
        ggplot2::geom_vline(xintercept = 0 #,
                            #color = urbnthemes::palette_urbn_gray[8]
        ) +
        ggplot2::geom_segment(ggplot2::aes(x = 0,
                                           xend = diff_data_city,
                                           y = census_var,
                                           yend = census_var) #,
                              #color = urbnthemes::palette_urbn_gray[6]
        ) +
        ggplot2:: geom_point(ggplot2::aes(color = pos_diff),
                             size = 3) +
        # Put text to left/right of 0 line to match equity tool
        ggplot2::geom_text(data = df_plot |>
                             dplyr::filter(diff_data_city >= 0),
                           ggplot2::aes(x = 0, y = census_var, label = census_var),
                           nudge_x  = -(max_val * 0.01),
                           hjust = "right",
                           size = 4) +
        ggplot2::geom_text(data = df_plot |>
                             dplyr::filter(diff_data_city < 0),
                           ggplot2::aes(x = 0, y = census_var, label = census_var),
                           nudge_x  = max_val * 0.01,
                           hjust = "left",
                           size = 4) +
        ggplot2::annotation_custom(underrep_label, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
        ggplot2::annotation_custom(overrep_label, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
        # ggplot2::scale_color_manual(values = c('positive' = urbnthemes::palette_urbn_diverging[1],
        #                               'negative' = urbnthemes::palette_urbn_diverging[7])) +
        ggplot2::scale_x_continuous(position = "top",
                                    limits = c(-max_val, max_val),
                                    labels = scales::percent) +
        ggplot2::labs(y = "", x = "") +
        ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                       panel.grid.minor = ggplot2::element_blank(),
                       axis.text.y = ggplot2::element_blank(),
                       panel.background = ggplot2::element_rect(
                         fill = "white",
                         colour = "black"
                       ),
                       plot.margin = ggplot2::margin(
                         r = 10,
                         l = 5,
                         t = 5,
                         b = 5
                       ),
                       legend.position = "none")

      print(plot)

      if(save_chart){
        ggplot2::ggsave(filename = file_path,
                        plot = plot,
                        width = 11,
                        height = 8.5,
                        units = "in")
      }

      return(plot)
    },

    #ERROR:
    error=function(e) {
      message('An Error Occurred')
      print(e)
    },

    #WARNING
    warning=function(w) {
      message('A Warning Occurred')
      print(w)
      return(NA)
    }

  )

}
