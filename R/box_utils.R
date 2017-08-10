`%>%` = magrittr::`%>%`

plot.sensebox = function (x) {
  # TODO: background map?
  geom = sf::st_geometry(x)
  plot(geom, graticule = st_crs(geom), axes = TRUE)
  invisible(x)
}

print.sensebox = function(x) {
  important_columns = c('name', 'exposure', 'lastMeasurement', 'phenomena')
  data = as.data.frame(x) # to get rid of the sf::`<-[` override..
  message(class(data))
  print(data[important_columns])
  invisible(x)
}

summary.sensebox = function(x) {
  df = as.data.frame(x) # the sf methods are messing with us again..

  cat('boxes total:', nrow(df), fill = T)
  cat('\nboxes by exposure:')
  table(df$exposure) %>% print()
  cat('\nboxes by model:')
  table(df$model) %>% print()
  cat('\n')

  diffNow = (lubridate::now() - df$lastMeasurement) %>% as.numeric(unit='hours')
  neverActive = df[is.na(df$lastMeasurement), ] %>% nrow()
  list(
    'last_measurement_within' = c(
      '1h' = nrow(df[diffNow <= 1, ]) - neverActive,
      '1d' = nrow(df[diffNow <= 24, ]) - neverActive,
      '30d' = nrow(df[diffNow <= 720, ]) - neverActive,
      '365d' = nrow(df[diffNow <= 8760, ]) - neverActive,
      'never' = neverActive
    )
  ) %>%
    print()

  oldest = df[df$createdAt == min(df$createdAt), ]
  newest = df[df$createdAt == max(df$createdAt), ]
  cat('oldest box:', format(oldest$createdAt, '%F %T'), paste0('(', oldest$name, ')'), fill = T)
  cat('newest box:', format(newest$createdAt, '%F %T'), paste0('(', newest$name, ')'), fill = T)

  cat('\nsensors per box:', fill = T)
  lapply(df$phenomena, length) %>%
    as.numeric() %>%
    summary() %>%
    print()

  invisible(x)
}

osem_phenomena = function (x) UseMethod('osem_phenomena')
osem_phenomena.default = function (x) stop('not implemented')
osem_phenomena.sensebox = function (x) {
  Reduce(`c`, x$phenomena) %>% # get all the row contents in a single vector
    table() %>%                # get the counts
    t() %>%                    # transform the table to an easier to work with df
    as.data.frame.matrix()
}
