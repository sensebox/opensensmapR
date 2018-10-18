# client for archive.opensensemap.org
# in this archive, a zip bundle for measurements of each box per day is provided.

#' Default endpoint for the archive download
#' front end domain is archive.opensensemap.org, but file download
#' is provided via sciebo
#' @export
osem_archive_endpoint = function () {
  'https://uni-muenster.sciebo.de/index.php/s/HyTbguBP4EkqBcp/download?path=/data'
}

#' Get day-wise measurements for a single box from the openSenseMap archive.
#' 
#' This function is significantly faster than `osem_measurements()` for large
#' time-frames, as dayly CSV dumps for each sensor from
#' <archive.opensensemap.org> are used.
#' Note that the latest data available is from the previous day.
#' By default, data for all sensors of a box is fetched, but you can select a
#' subset with a `dplyr`-style NSE filter expression.
#' 
#' @export
osem_measurements_archive = function (x, ...) UseMethod('osem_measurements_archive')

#' @export
osem_measurements_archive.default = function (x, ...) {
  # NOTE: to implement for a different class:
  # in order to call `archive_fetch_measurements()`, `box` must be a dataframe
  # with a single row and the columns `X_id` and `name`
  stop(paste('not implemented for class', toString(class(x))))
}

#' @describeIn osem_measurements_archive Get daywise measurements for one or
#' more sensors of a single box
#' @export
#' @examples 
#' 
#' \donttest{
#'   # fetch measurements for a single day
#'   box = osem_box('593bcd656ccf3b0011791f5a')
#'   m = osem_measurements_archive(box, as.POSIXlt('2018-09-13'))
#'   
#'   # fetch measurements for a date range and selected sensors
#'   sensors = ~ phenomenon %in% c('Temperatur', 'Beleuchtungsstärke')
#'   m = osem_measurements_archive(box, as.POSIXlt('2018-09-01'), as.POSIXlt('2018-09-30'), sensorFilter = sensors)
#' }
osem_measurements_archive.sensebox = function (x, fromDate, toDate = fromDate, sensorFilter = ~ T, progress = T) {
  if (nrow(x) != 1)
    stop('this function only works for exactly one senseBox!')
  
  # filter sensors using NSE, for example: `~ phenomenon == 'Temperatur'`
  sensors = x$sensors[[1]] %>%
    dplyr::filter(lazyeval::f_eval(sensorFilter, .))
  
  # fetch each sensor separately
  dfs = by(sensors, 1:nrow(sensors), function (sensor) {
    df = archive_fetch_measurements(x, sensor$id, fromDate, toDate, progress) %>%
      dplyr::select(createdAt, value) %>%
      #dplyr::mutate(unit = sensor$unit, sensor = sensor$sensor) %>% # inject sensor metadata
      dplyr::rename_at(., 'value', function(v) sensor$phenomenon)
  })
  
  # merge all data.frames by timestamp
  dfs %>% purrr::reduce(dplyr::full_join, 'createdAt')
}

#' fetch measurements from archive from a single box, and a single sensor
#'
#' @param box 
#' @param sensor 
#' @param fromDate 
#' @param toDate 
#' @param progress 
#'
#' @return
#'
#' @examples
archive_fetch_measurements = function (box, sensor, fromDate, toDate, progress) {
  dates = list()
  from = fromDate
  while (from <= toDate) {
    dates = append(dates, list(from))
    from = from + as.difftime(1, units = 'days')
  }
  
  http_handle = httr::handle(osem_archive_endpoint()) # reuse the http connection for speed! 
  progress = if (progress && !is_non_interactive()) httr::progress() else NULL
  
  measurements = lapply(dates, function(date) {
    url =  build_archive_url(date, box, sensor)
    res = httr::GET(url, progress, handle = http_handle)
  
    if (httr::http_error(res)) {
      warning(paste(
        httr::status_code(res),
        'on day', format.Date(date, '%F'),
        'for sensor', sensor
      ))
      
      if (httr::status_code(res) == 404)
        return(as.data.frame)
    }
 
    measurements = httr::content(res, type = 'text', encoding = 'UTF-8') %>%
      parse_measurement_csv
  })

  measurements %>% dplyr::bind_rows()
}

#' returns URL to fetch measurements from a sensor for a specific date,
#' based on `osem_archive_endpoint()`
build_archive_url = function (date, box, sensor) {
  sensorId = sensor
  d =  format.Date(date, '%F')
  format = 'csv'
  
  paste(
    osem_archive_endpoint(),
    d,
    osem_box_to_archivename(box),
    paste(paste(sensorId, d, sep = '-'), format, sep = '.'),
    sep = '/'
  )
}

#' replace chars in box name according to archive script:
#' https://github.com/sensebox/osem-archiver/blob/612e14b/helpers.sh#L66
osem_box_to_archivename = function (box) {
  name = gsub('[^A-Za-z0-9._-]', '_', box$name)
  paste(box$X_id, name, sep='-')
}
