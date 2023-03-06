#' @export
plot.osem_measurements = function (x, ..., mar = c(2, 4, 1, 1)) {
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  par(mar = mar)
  plot(value~createdAt, x, col = factor(x$sensorId), xlab = NA, ylab = x$unit[1], ...)
  invisible(x)
}

#' @export
print.osem_measurements = function (x, ...) {
  print.data.frame(x, ...)
  invisible(x)
}

#' Converts a foreign object to an osem_measurements data.frame.
#' @param x A data.frame to attach the class to.
#'   Should have at least a `value` and `createdAt` column.
#' @return data.frame of class \code{osem_measurements}
#' @export
osem_as_measurements = function(x) {
  ret = tibble::as_tibble(x)
  class(ret) = c('osem_measurements', class(ret))
  ret
}
