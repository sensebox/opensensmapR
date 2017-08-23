#' @export
plot.osem_measurements = function (x, ...) {
  # TODO: group/color by sensor_id
  plot(value~createdAt, x, col = x$sensorId, ...)
  invisible(x)
}
