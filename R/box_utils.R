#' @export
plot.sensebox = function (x, ...) {
  if (
    !requireNamespace("sf", quietly = TRUE) ||
    !requireNamespace("maps", quietly = TRUE) ||
    !requireNamespace("maptools", quietly = TRUE) ||
    !requireNamespace("rgeos", quietly = TRUE)
  ) {
    stop('this functions requires the packages sf, maps, maptools, rgeos')
  }

  geom = x %>%
    osem_as_sf() %>%
    sf::st_geometry()

  bbox = sf::st_bbox(geom)

  library(maps)
  world = maps::map('world', plot = FALSE, fill = TRUE) %>%
    sf::st_as_sf() %>%
    sf::st_geometry()

  oldpar = par()
  par(mar = c(2,2,1,1))
  plot(world, col = 'gray', xlim = bbox[c(1,3)], ylim = bbox[c(2,4)], axes = T)
  plot(geom, add = T, col = x$exposure)
  legend('left', legend = levels(x$exposure), col = 1:length(x$exposure), pch = 1)
  par(mar = oldpar$mar)

  invisible(x)
}

#' @export
print.sensebox = function(x, ...) {
  important_columns = c('name', 'exposure', 'lastMeasurement', 'phenomena')
  data = as.data.frame(x)
  print(data[important_columns], ...)

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

  diffNow = (utc_date(Sys.time()) - object$lastMeasurement) %>% as.numeric(unit='hours')
  neverActive = object[is.na(object$lastMeasurement), ] %>% nrow()
  list(
    'last_measurement_within' = c(
      '1h' = nrow(object[diffNow <= 1, ]) - neverActive,
      '1d' = nrow(object[diffNow <= 24, ]) - neverActive,
      '30d' = nrow(object[diffNow <= 720, ]) - neverActive,
      '365d' = nrow(object[diffNow <= 8760, ]) - neverActive,
      'never' = neverActive
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

#' Converts a foreign object to an sensebox data.frame.
#' @param x A data.frame to attach the class to
#' @export
osem_as_sensebox = function(x) {
  ret = as.data.frame(x)
  class(ret) = c('sensebox', class(x))
  ret
}

#' @export
filter_.sensebox = dplyr_class_wrapper(osem_as_sensebox)
#' @export
filter.sensebox = dplyr_class_wrapper(osem_as_sensebox)
#' @export
mutate_.sensebox = dplyr_class_wrapper(osem_as_sensebox)
#' @export
mutate.sensebox = dplyr_class_wrapper(osem_as_sensebox)

#' maintains class / attributes after subsetting
#' @noRd
#' @export
`[.sensebox` = function(x, i, ...) {
  s = NextMethod('[')
  mostattributes(s) = attributes(x)
  s
}
