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
  plot(world, col = 'gray', xlim = bbox[c(1, 3)], ylim = bbox[c(2, 4)], axes = TRUE, ...)
  plot(geom, add = TRUE, col = x$exposure, ...)
  legend('left', legend = levels(x$exposure), col = 1:length(x$exposure), pch = 1)
  par(mar = oldpar$mar)

  invisible(x)
}

#' @export
print.sensebox = function(x, columns = c('name', 'exposure', 'lastMeasurement', 'phenomena'), ...) {
  data = as.data.frame(x)
  print(dplyr::select(data, dplyr::one_of(columns)), ...)
  invisible(x)
}

#' @export
summary.sensebox = function(object, ...) {
  cat('boxes total:', nrow(object), fill = TRUE)
  cat('\nboxes by exposure:')
  table(object$exposure) %>% print()
  cat('\nboxes by model:')
  table(object$model) %>% print()
  cat('\n')

  diffNow = (date_as_utc(Sys.time()) - object$lastMeasurement) %>% as.numeric(unit = 'hours')
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
  cat('oldest box:', format(oldest$createdAt, '%F %T'), paste0('(', oldest$name, ')'), fill = TRUE)
  cat('newest box:', format(newest$createdAt, '%F %T'), paste0('(', newest$name, ')'), fill = TRUE)

  cat('\nsensors per box:', fill = TRUE)
  lapply(object$phenomena, length) %>%
    as.numeric() %>%
    summary() %>%
    print()

  invisible(object)
}

#' Converts a foreign object to a sensebox data.frame.
#' @param x A data.frame to attach the class to
#' @export
osem_as_sensebox = function(x) {
  ret = as.data.frame(x)
  class(ret) = c('sensebox', class(x))
  ret
}
