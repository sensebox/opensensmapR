#' @export
plot.sensebox = function (x, ..., mar = c(2, 2, 1, 1)) {
  if (
    !requireNamespace('sf', quietly = TRUE) ||
    !requireNamespace('maps', quietly = TRUE) ||
    !requireNamespace('maptools', quietly = TRUE) ||
    !requireNamespace('rgeos', quietly = TRUE)
  ) {
    stop('this functions requires additional packages. install them with
    install.packages(c("sf", "maps", "maptools", "rgeos"))')
  }

  geom = x %>%
    sf::st_as_sf() %>%
    sf::st_geometry()

  bbox = sf::st_bbox(geom)

  world = maps::map('world', plot = FALSE, fill = TRUE) %>%
    sf::st_as_sf() %>%
    sf::st_geometry()

  oldpar = par()
  par(mar = mar)
  plot(world, col = 'gray', xlim = bbox[c(1, 3)], ylim = bbox[c(2, 4)], axes = T)
  plot(geom, add = T, col = x$exposure)
  legend('left', legend = levels(x$exposure), col = 1:length(x$exposure), pch = 1)
  par(mar = oldpar$mar)

  invisible(x)
}

#' @export
print.sensebox = function(x, ...) {
  important_columns = c('name', 'exposure', 'lastMeasurement', 'phenomena')
  data = as.data.frame(x)
  available_columns = important_columns %in% names(data)
  print(data[available_columns], ...)

  invisible(x)
}

#' @export
summary.sensebox = function(object, ...) {
  cat('boxes total:', nrow(object), fill = T)
  cat('\nboxes by exposure:')
  table(object$exposure) %>% print()
  cat('\nboxes by model:')
  table(object$model) %>% print()
  cat('\n')

  diffNow = (utc_date(Sys.time()) - object$lastMeasurement) %>% as.numeric(unit = 'hours')
  list(
    'last_measurement_within' = c(
      '1h'    = nrow(dplyr::filter(object, diffNow <= 1)),
      '1d'    = nrow(dplyr::filter(object, diffNow <= 24)),
      '30d'   = nrow(dplyr::filter(object, diffNow <= 720)),
      '365d'  = nrow(dplyr::filter(object, diffNow <= 8760)),
      'never' = nrow(dplyr::filter(object, is.na(lastMeasurement)))
    )
  ) %>% print()

  oldest = object[object$createdAt == min(object$createdAt), ]
  newest = object[object$createdAt == max(object$createdAt), ]
  cat('oldest box:', format(oldest$createdAt, '%F %T'), paste0('(', oldest$name, ')'), fill = T)
  cat('newest box:', format(newest$createdAt, '%F %T'), paste0('(', newest$name, ')'), fill = T)

  cat('\nsensors per box:', fill = T)
  lapply(object$phenomena, length) %>%
    as.numeric() %>%
    summary() %>%
    print()

  invisible(object)
}

# ==============================================================================
#
#' Converts a foreign object to a sensebox data.frame.
#' @param x A data.frame to attach the class to
#' @export
osem_as_sensebox = function(x) {
  ret = as.data.frame(x)
  class(ret) = c('sensebox', class(x))
  ret
}

#' Return rows with matching conditions, while maintaining class & attributes
#' @param .data A sensebox data.frame to filter
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{filter}}
#' @export
filter.sensebox = dplyr_class_wrapper(osem_as_sensebox)

#' Add new variables to the data, while maintaining class & attributes
#' @param .data A sensebox data.frame to mutate
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{mutate}}
#' @export
mutate.sensebox = dplyr_class_wrapper(osem_as_sensebox)

# ==============================================================================
#
#' maintains class / attributes after subsetting
#' @noRd
#' @export
`[.sensebox` = function(x, i, ...) {
  s = NextMethod('[')
  mostattributes(s) = attributes(s)
  s
}

# ==============================================================================
#
#' Convert a \code{sensebox} dataframe to an \code{\link[sf]{st_sf}} object.
#'
#' @param x The object to convert
#' @param ... maybe more objects to convert
#' @return The object with an st_geometry column attached.
#' @export
st_as_sf.sensebox = function (x, ...) {
  NextMethod(x, ..., coords = c('lon', 'lat'), crs = 4326)
}
