#' @export
plot.osem_measurements = function (x, ...) {
  oldpar = par()
  par(mar = c(2,4,1,1))
  plot(value~createdAt, x, col = x$sensorId, xlab = NA, ylab = x$unit[1], ...)
  par(mar = oldpar$mar)
  invisible(x)
}
