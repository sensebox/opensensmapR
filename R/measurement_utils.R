#' Plot openSenseMap Measurements by Time & Value
#'
#' @param x An \code{osem_measurements} \code{data.frame}.
#' @param ... Any parameters you would otherwise pass to \code{plot.formula}.
#'
#' @return The input data is returned
#' @export
#'
#' @examples
#' osem_boxes(grouptag = 'ifgi') %>%
#'   osem_measurements(phenomenon = 'Temperatur') %>%
#'   plot()
plot.osem_measurements = function (x, ...) {
  # TODO: group/color by sensor_id
  plot(value~createdAt, x, ...)
  invisible(x)
}
