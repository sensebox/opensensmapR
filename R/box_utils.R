#' @export
plot.sensebox = function (x, ...) {
  # TODO: background map (maps::world), graticule?
  geom = x %>%
    osem_as_sf() %>%
    sf::st_geometry()

  # FIXME:trying to add graticule crashes RStudio?!
  plot(geom, ..., axes = T) #graticule = sf::st_crs(sf)

  invisible(x)
}

#' @export
print.sensebox = function(x, ...) {
  important_columns = c('name', 'exposure', 'lastMeasurement', 'phenomena')
  data = as.data.frame(x) # to get rid of the sf::`<-[` override..
  print(data[important_columns], ...)

  invisible(x)
}

#' @export
summary.sensebox = function(object, ...) {
  cat('box total:', nrow(object), fill = T)
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
  ) %>%
    print()

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
