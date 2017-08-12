`%>%` = magrittr::`%>%`

plot.sensebox = function (x, ...) {
  # TODO: background map (maps::world), graticule?
  geom = x %>%
    osem_as_sf() %>%
    sf::st_geometry()

  # FIXME:trying to add graticule crashes RStudio?!
  plot(geom, ..., axes = T) #graticule = sf::st_crs(sf)

  invisible(x)
}

print.sensebox = function(x, ...) {
  important_columns = c('name', 'exposure', 'lastMeasurement', 'phenomena')
  data = as.data.frame(x) # to get rid of the sf::`<-[` override..
  print(data[important_columns], ...)
  invisible(x)
}

summary.sensebox = function(x, ...) {
  cat('boxes total:', nrow(x), fill = T)
  cat('\nboxes by exposure:')
  table(x$exposure) %>% print()
  cat('\nboxes by model:')
  table(x$model) %>% print()
  cat('\n')

  diffNow = (utc_time(Sys.time()) - x$lastMeasurement) %>% as.numeric(unit='hours')
  neverActive = x[is.na(x$lastMeasurement), ] %>% nrow()
  list(
    'last_measurement_within' = c(
      '1h' = nrow(x[diffNow <= 1, ]) - neverActive,
      '1d' = nrow(x[diffNow <= 24, ]) - neverActive,
      '30d' = nrow(x[diffNow <= 720, ]) - neverActive,
      '365d' = nrow(x[diffNow <= 8760, ]) - neverActive,
      'never' = neverActive
    )
  ) %>%
    print()

  oldest = x[x$createdAt == min(x$createdAt), ]
  newest = x[x$createdAt == max(x$createdAt), ]
  cat('oldest box:', format(oldest$createdAt, '%F %T'), paste0('(', oldest$name, ')'), fill = T)
  cat('newest box:', format(newest$createdAt, '%F %T'), paste0('(', newest$name, ')'), fill = T)

  cat('\nsensors per box:', fill = T)
  lapply(x$phenomena, length) %>%
    as.numeric() %>%
    summary() %>%
    print()

  invisible(x)
}

osem_phenomena = function (x) UseMethod('osem_phenomena')
osem_phenomena.default = function (x) stop('not implemented')
osem_phenomena.sensebox = function (x) {
  Reduce(`c`, x$phenomena) %>% # get all the row contents in a single vector
    table() %>%                # get count for each phenomenon
    t() %>%                    # transform the table to a df
    as.data.frame.matrix()
}
