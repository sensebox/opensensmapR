# ==============================================================================
#
#' Convert a \code{sensebox} or \code{osem_measurements} dataframe to an
#' \code{\link[sf]{st_sf}} object.
#'
#' @param x The object to convert
#' @param ... maybe more objects to convert
#' @return The object with an st_geometry column attached.
#' @export
osem_as_sf = function (x, ...) {
  sf::st_as_sf(x, ..., coords = c('lon', 'lat'), crs = 4326)
}

# parses from/to params for get_measurements_ and get_boxes_
parse_dateparams = function (from, to) {
  from = utc_date(from)
  to = utc_date(to)
  if (from - to > 0) stop('"from" must be earlier than "to"')
  c(date_as_isostring(from), date_as_isostring(to))
}

# NOTE: cannot handle mixed vectors of POSIXlt and POSIXct
utc_date = function (date) {
  time = as.POSIXct(date)
  attr(time, 'tzone') = 'UTC'
  time
}

# NOTE: cannot handle mixed vectors of POSIXlt and POSIXct
date_as_isostring = function (date) format.Date(date, format = '%FT%TZ')

#' Simple factory function meant to implement dplyr functions for other classes,
#' which call an callback to attach the original class again after the fact.
#'
#' @param callback The function to call after the dplyr function
#' @noRd
dplyr_class_wrapper = function(callback) {
  function(.data, ..., .dots) callback(NextMethod())
}

