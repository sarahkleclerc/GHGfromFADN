#' Remove outliers according to z-score
#'
#' @description
#' z-score is the number of standard deviations from the mean.
#' Observation i is considered outlier if |z_i|>3
#'
#' @usage zscore(data, variable, group = NULL, threshold = 3)
#'
#' @param data a dataframe
#' @param variable the variable of interest
#' @param group a grouping variable. Default is NULL where no grouping variable.
#' @param threshold a number. Threshold for z score. We keep z_i<= threshold.
#'
#' @return Data without outliers
#'
#' @import rlang
#' @import dplyr
#'
#' @export

zscore <- function(data, variable, group = NULL, threshold = 3){
  if(is_null(group)){
    data %>%
      mutate(z_score = (variable - mean(variable)) / sd(variable)) %>%
      ungroup() %>%
      filter(z_score <= threshold)
  } else {
    data %>%
      group_by(group) %>%
      mutate(z_score = (variable - mean(variable)) / sd(variable)) %>%
      ungroup() %>%
      filter(z_score <= threshold)
  }
}

#' Z-score plot
#'
#' @description
#' z-score is the number of standard deviations from the mean.
#' Observation i is considered outlier if |z_i|>3
#'
#' @usage plot_score(data, variable, threshold = 3, hline = NULL)
#'
#' @param data a dataframe
#' @param variable the variable of interest
#' @param threshold a number. Threshold for z score. We keep z_i<= threshold
#' @param hline a number. Level of the horizontal dash line represented on the plot
#'
#' @return Plot of the z-score with thresholds
#'
#' @import rlang
#' @import dplyr
#' @import ggplot2
#' @importFrom gridExtra grid.arrange
#'
#' @export

plot_score <- function(data, variable, threshold = 3, hline = NULL){
  data <- data %>%
    GHGfromFADN::zscore(variable = variable, group = NULL, threshold = threshold)

  if(is_null(hline)){ # without dashed hline

    main <- ggplot(data, aes(x = 1:nrow(data), y = get(variable, data))) +
      geom_point(aes(colour = z_score > threshold), alpha = 0.7, size = 2) +
      theme_minimal() + xlab("") +
      scale_colour_manual(values = c("darkblue", "red"))
    side <- ggplot(data, aes(x = get(variable, data))) +
      geom_histogram(fill = "steelblue", alpha = 0.5, binwidth = 0.1) +
      theme_minimal() + coord_flip() + xlab("") + ylab("") + theme(axis.text = element_blank())

    gridExtra::grid.arrange(main, side, ncol = 2, widths = c(3, 1))

  } else { # with dashed hline

    main <- ggplot(data, aes(x = 1:nrow(data), y = get(variable, data))) +
      geom_point(aes(colour = z_score > threshold), alpha = 0.7, size = 2) +
      theme_minimal() + xlab("") +
      geom_hline(yintercept = hline, colour = "blue", size = 1.5, linetype = "dashed") +
      scale_colour_manual(values = c("darkblue", "red"))
    side <- ggplot(data, aes(x = get(variable, data))) +
      geom_histogram(fill = "steelblue", alpha = 0.5, binwidth = 0.1) +
      theme_minimal() + coord_flip() + xlab("") + ylab("") + theme(axis.text = element_blank())

    gridExtra::grid.arrange(main, side, ncol = 2, widths = c(3, 1))
  }

}
