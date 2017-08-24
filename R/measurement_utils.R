#' @export
plot.osem_measurements = function (x, ...) {
  oldpar = par()
  par(mar = c(2,4,1,1))
  plot(value~createdAt, x, col = factor(x$sensorId), xlab = NA, ylab = x$unit[1], ...)
  par(mar = oldpar$mar)
  invisible(x)
}

#' Converts a foreign object to an osem_measurements data.frame.
#' @param x A data.frame to attach the class to
#' @export
osem_as_measurements = function(x) {
  ret = as.data.frame(x)
  class(ret) = c('osem_measurements', class(x))
  ret
}

#' @export
filter_.osem_measurements = dplyr_class_wrapper(osem_as_measurements)
#' @export
filter.osem_measurements = dplyr_class_wrapper(osem_as_measurements)
#' @export
mutate_.osem_measurements = dplyr_class_wrapper(osem_as_measurements)
#' @export
mutate.osem_measurements = dplyr_class_wrapper(osem_as_measurements)

#' maintains class / attributes after subsetting
#' @noRd
#' @export
`[.osem_measurements` = function(x, i, ...) {
  s = NextMethod('[')
  mostattributes(s) = attributes(x)
  s
}

