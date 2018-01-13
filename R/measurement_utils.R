#' @export
plot.osem_measurements = function (x, ..., mar = c(2,4,1,1)) {
  oldpar = par()
  par(mar = mar)
  plot(value~createdAt, x, col = factor(x$sensorId), xlab = NA, ylab = x$unit[1], ...)
  par(mar = oldpar$mar)
  invisible(x)
}

#' @export
print.osem_measurements = function (x, ...) {
  print.data.frame(x, ...)
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

#' Return rows with matching conditions, while maintaining class & attributes
#' @param .data A osem_measurements data.frame to filter
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{filter}}
#' @export
filter.osem_measurements = dplyr_class_wrapper(osem_as_measurements)

#' Add new variables to the data, while maintaining class & attributes
#' @param .data A osem_measurements data.frame to mutate
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{mutate}}
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

# ==============================================================================
#
#' Convert a \code{osem_measurements} dataframe to an \code{\link[sf]{st_sf}} object.
#'
#' @param x The object to convert
#' @param ... maybe more objects to convert
#' @return The object with an st_geometry column attached.
#' @export
st_as_sf.osem_measurements = function (x, ...) {
  NextMethod(x, ..., coords = c('lon', 'lat'), crs = 4326)
}
