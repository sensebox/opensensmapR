# ==============================================================================
#
#' Fetch the Measurements of a Phenomenon on opensensemap.org
#'
#' Measurements can be retrieved either for a set of boxes, or through a spatial
#' bounding box filter. To get all measurements, the \code{default} function applies
#' a bounding box spanning the whole world.
#'
#' @param x Depending on the method, either
#'   \enumerate{
#'     \item a \code{chr} specifying the phenomenon, see \code{phenomenon}
#'     \item a \code{\link[sf]{st_bbox}} to select sensors spatially,
#'     \item a \code{sensebox data.frame} to select boxes from which
#'       measurements will be retrieved,
#'   }
#' @param ... see parameters below
#' @param phenomenon The phenomenon to retrieve measurements for
#' @param exposure Filter sensors by their exposure ('indoor', 'outdoor', 'mobile')
#' @param from A \code{POSIXt} like object to select a time interval
#' @param to A \code{POSIXt} like object to select a time interval
#' @param columns Select specific column in the output (see openSenseMap API documentation)
#' @param endpoint The URL of the openSenseMap API
#' @param progress Whether to print download progress information
#' @param cache Whether to cache the result, defaults to false.
#'   If a valid path to a directory is given, the response will be cached there. Subsequent identical requests will return the cached data instead.
#'
#' @return An \code{osem_measurements data.frame} containing the
#'   requested measurements
#'
#' @export
#' @seealso \href{https://docs.opensensemap.org/#api-Measurements-getDataMulti}{openSenseMap API documentation (web)}
#' @seealso \code{\link{osem_box}}
#' @seealso \code{\link{osem_boxes}}
#' @seealso \code{\link{osem_clear_cache}}
osem_measurements = function (x, ...) UseMethod('osem_measurements')

# ==============================================================================
#
#' @describeIn osem_measurements Get measurements from \strong{all} senseBoxes.
#' @export
#' @examples
#' \donttest{
#'   # get measurements from all boxes on the phenomenon 'PM10' from the last 48h
#'   m = osem_measurements('PM10')
#'
#'   # get measurements from all mobile boxes on the phenomenon 'PM10' from the last 48h
#'   m = osem_measurements('PM10', exposure = 'mobile')
#'
#'   # get measurements and cache them locally in the working directory.
#'   # subsequent identical requests will load from the cache instead, ensuring
#'   # reproducibility and saving time and bandwidth!
#'   m = osem_measurements('PM10', exposure = 'mobile', cache = getwd())
#'   m = osem_measurements('PM10', exposure = 'mobile', cache = getwd())
#'
#'   # get measurements returning a custom selection of columns
#'   m = osem_measurements('PM10', exposure = 'mobile', columns = c(
#'     'value',
#'     'boxId',
#'     'sensorType',
#'     'lat',
#'     'lon',
#'     'height'
#'   ))
#' }
osem_measurements.default = function (x, ...) {
  bbox = structure(c(-180, -90, 180, 90), class = 'bbox')
  osem_measurements(bbox, x, ...)
}

# ==============================================================================
#
#' @describeIn osem_measurements Get measurements by a spatial filter.
#' @export
#' @examples
#' \donttest{
#'   # get measurements from sensors within a custom WGS84 bounding box
#'   bbox = structure(c(7, 51, 8, 52), class = 'bbox')
#'   m = osem_measurements(bbox, 'Temperatur')
#'
#'   # construct a bounding box 12km around berlin using the sf package,
#'   # and get measurements from stations within that box
#'   library(sf)
#'   library(units)
#'   bbox2 = st_point(c(13.4034, 52.5120)) %>%
#'     st_sfc(crs = 4326) %>%
#'     st_transform(3857) %>% # allow setting a buffer in meters
#'     st_buffer(set_units(12, km)) %>%
#'     st_transform(4326) %>% # the opensensemap expects WGS 84
#'     st_bbox()
#'   m = osem_measurements(bbox2, 'Temperatur', exposure = 'outdoor')
#'
#'   # construct a bounding box from two points,
#'   # and get measurements from stations within that box
#'   points = st_multipoint(matrix(c(7.5, 7.8, 51.7, 52), 2, 2))
#'   bbox3 = st_bbox(points)
#'   m = osem_measurements(bbox2, 'Temperatur', exposure = 'outdoor')
#' }
osem_measurements.bbox = function (x, phenomenon, exposure = NA,
                                   from = NA, to = NA, columns = NA,
                                   ...,
                                   endpoint = osem_endpoint(),
                                   progress = T,
                                   cache = NA) {
  bbox = x
  environment() %>%
    as.list() %>%
    parse_get_measurements_params() %>%
    paged_measurements_req()
}

# ==============================================================================
#
#' @describeIn osem_measurements Get measurements from a set of senseBoxes.
#' @export
#' @examples
#' \donttest{
#'   # get measurements from a set of boxes
#'   b = osem_boxes(grouptag = 'ifgi')
#'   m4 = osem_measurements(b, phenomenon = 'Temperatur')
#'
#'   # ...or a single box
#'   b = osem_box('57000b8745fd40c8196ad04c')
#'   m5 = osem_measurements(b, phenomenon = 'Temperatur')
#'
#'   # get measurements from a single box on the from the last 40 days.
#'   # requests are paged for long time frames, so the APIs limitation
#'   # does not apply!
#'   library(lubridate)
#'   m1 = osem_measurements(
#'     b,
#'     'Temperatur',
#'     to = now(),
#'     from = now() - days(40)
#'   )
#' }
osem_measurements.sensebox = function (x, phenomenon, exposure = NA,
                                       from = NA, to = NA, columns = NA,
                                       ...,
                                       endpoint = osem_endpoint(),
                                       progress = T,
                                       cache = NA) {
  boxes = x
  environment() %>%
    as.list() %>%
    parse_get_measurements_params() %>%
    paged_measurements_req()
}

# ==============================================================================
#
#' Validates and parses the Parameters for use in \code{osem_measurements()}
#' and sets a default selection of columns, if unspecified.
#' Dates are not stringified!
#'
#' @param params A named \code{list} of parameters
#' @return A named \code{list} of parsed parameters.
#' @noRd
parse_get_measurements_params = function (params) {
  if (is.symbol(params$phenomenon) || is.null(params$phenomenon) || is.na(params$phenomenon))
    stop('Parameter "phenomenon" is required')

  if (
    (!is.na(params$from) && is.na(params$to)) ||
    (!is.na(params$to) && is.na(params$from))
  ) stop('specify "from" only together with "to"')

  if (
    (!is.null(params$bbox) && !is.null(params$boxes)) ||
    (is.null(params$bbox) && is.null(params$boxes))
  ) stop('Specify either "bbox" or "boxes"')

  query = list(
    endpoint = params$endpoint,
    phenomenon = params$phenomenon,
    progress = params$progress,
    cache = params$cache
  )

  if (!is.null(params$boxes))  query$boxId = paste(params$boxes$X_id, collapse = ',')
  if (!is.null(params$bbox))   query$bbox = paste(params$bbox, collapse = ',')

  if (!is.na(params$from) && !is.na(params$to)) {
    parse_dateparams(params$from, params$to) # only for validation sideeffect
    query$`from-date` = date_as_utc(params$from)
    query$`to-date` = date_as_utc(params$to)
  }

  if (!is.na(params$exposure)) query$exposure = params$exposure
  if (!any(is.na(params$columns)))
    query$columns = paste(params$columns, collapse = ',')
  else
    query$columns = 'value,createdAt,lon,lat,sensorId,unit'

  query
}

paged_measurements_req = function (query) {
  # no paged requests when dates are not provided
  if (!all(c('from-date', 'to-date') %in% names(query)))
    return(do.call(get_measurements_, query))

  # auto paging: make a request for one 31day interval each (max supprted length)
  # generate a list 31day intervals
  from = query$`from-date`
  to = query$`to-date`
  dates = list()
  while (from < to) {
    in31days = from + as.difftime(31, units = 'days')
    dates = append(dates, list(list(from = from, to = min(in31days, to))))
    from = in31days + as.difftime(1, units = 'secs')
  }

  # use the dates as pages for multiple requests
  df = lapply(dates, function(page) {
    query$`from-date` = date_as_isostring(page$from)
    query$`to-date` = date_as_isostring(page$to)
    res = do.call(get_measurements_, query)

    if (query$progress && !is_non_interactive())
      cat(paste(query$`from-date`, query$`to-date`, sep = ' - '), '\n')

    res
  }) %>%
    dplyr::bind_rows()

  # coerce all character columns (sensorId, unit, ...) to factors AFTER binding
  df[sapply(df, is.character)] = lapply(df[sapply(df, is.character)], as.factor)
  df
}
