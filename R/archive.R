# client for archive.opensensemap.org
# in this archive, CSV files for measurements of each sensor per day is provided.

default_archive_url = 'https://archive.opensensemap.org/'

#' Returns the default endpoint for the archive *download*
#' While the front end domain is archive.opensensemap.org, file downloads
#' are provided via sciebo.
osem_archive_endpoint = function () default_archive_url 

#' Fetch day-wise measurements for a single box from the openSenseMap archive.
#'
#' This function is significantly faster than \code{\link{osem_measurements}} for large
#' time-frames, as daily CSV dumps for each sensor from
#' \href{https://archive.opensensemap.org}{archive.opensensemap.org} are used.
#' Note that the latest data available is from the previous day.
#'
#' By default, data for all sensors of a box is fetched, but you can select a
#' subset with a \code{\link[dplyr]{dplyr}}-style NSE filter expression.
#'
#' The function will warn when no data is available in the selected period,
#' but continue the remaining download.
#'
#' @param x A `sensebox data.frame` of a single box, as retrieved via \code{\link{osem_box}},
#'   to download measurements for.
#' @param ... see parameters below
#' @param fromDate Start date for measurement download, must be convertable via `as.Date`.
#' @param toDate End date for measurement download (inclusive).
#' @param sensorFilter A NSE formula matching to \code{x$sensors}, selecting a subset of sensors.
#' @param progress Whether to print download progress information, defaults to \code{TRUE}.
#' @return A \code{tbl_df} containing observations of all selected sensors for each time stamp.
#'
#' @seealso \href{https://archive.opensensemap.org}{openSenseMap archive}
#' @seealso \code{\link{osem_measurements}}
#' @seealso \code{\link{osem_box}}
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


# ==============================================================================
#
#' @describeIn osem_measurements_archive Get daywise measurements for one or more sensors of a single box.
#' @export
#' @examples
#' \donttest{
#'   # fetch measurements for a single day
#'   box = osem_box('593bcd656ccf3b0011791f5a')
#'   m = osem_measurements_archive(box, as.POSIXlt('2018-09-13'))
#'
#'   # fetch measurements for a date range and selected sensors
#'   sensors = ~ phenomenon %in% c('Temperatur', 'Beleuchtungsstärke')
#'   m = osem_measurements_archive(
#'     box,
#'     as.POSIXlt('2018-09-01'), as.POSIXlt('2018-09-30'),
#'     sensorFilter = sensors
#'   )
#' }
osem_measurements_archive.sensebox = function (x, fromDate, toDate = fromDate, sensorFilter = ~ TRUE, ..., progress = TRUE) {
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
#' @param box A sensebox data.frame with a single box
#' @param sensorId Character specifying the sensor
#' @param fromDate Start date for measurement download, must be convertable via `as.Date`.
#' @param toDate End date for measurement download (inclusive).
#' @param progress whether to print progress
#' @return A \code{tbl_df} containing observations of all selected sensors for each time stamp.
archive_fetch_measurements = function (box, sensorId, fromDate, toDate, progress) {
  osem_ensure_archive_available()

  dates = list()
  from = fromDate
  while (from <= toDate) {
    dates = append(dates, list(from))
    from = from + as.difftime(1, units = 'days')
  }

  http_handle = httr::handle(osem_archive_endpoint()) # reuse the http connection for speed!
  progress = if (progress && !is_non_interactive()) httr::progress() else NULL

  measurements = lapply(dates, function(date) {
    url =  build_archive_url(date, box, sensorId)
    res = httr::GET(url, progress, handle = http_handle)

    if (httr::http_error(res)) {
      warning(paste(
        httr::status_code(res),
        'on day', format.Date(date, '%F'),
        'for sensor', sensorId
      ))

      if (httr::status_code(res) == 404)
        return(data.frame(createdAt = as.POSIXlt(x = integer(0), origin = date), value = double()))
    }

    measurements = httr::content(res, type = 'text', encoding = 'UTF-8') %>%
      parse_measurement_csv
  })

  measurements %>% dplyr::bind_rows()
}

#' returns URL to fetch measurements from a sensor for a specific date,
#' based on `osem_archive_endpoint()`
#' @noRd
build_archive_url = function (date, box, sensorId) {
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
#'
#' @param box A sensebox data.frame
#' @return character with archive identifier for each box
osem_box_to_archivename = function (box) {
  name = gsub('[^A-Za-z0-9._-]', '_', box$name)
  paste(box$X_id, name, sep = '-')
}

#' Check if the given openSenseMap archive endpoint is available
#' @param endpoint The archive base URL to check, defaulting to \code{\link{osem_archive_endpoint}}
#' @return \code{TRUE} if the archive is available, otherwise \code{stop()} is called.
osem_ensure_archive_available = function(endpoint = osem_archive_endpoint()) {
  code = FALSE
  try({
    code = httr::status_code(httr::GET(endpoint))
  }, silent = TRUE)
  
  if (code == 200)
    return(TRUE)
  
  errtext = paste('The archive at', endpoint, 'is currently not available.')
  if (code != FALSE)
    errtext = paste0(errtext, ' (HTTP code ', code, ')')
  stop(paste(errtext, collapse='\n  '), call. = FALSE)
  FALSE
}