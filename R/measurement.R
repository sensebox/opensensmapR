# ==============================================================================
#
#' Get the Measurements of a Phenomenon on opensensemap.org
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
#' @param columns Select specific column in the output (see oSeM documentation)
#' @param endpoint The URL of the openSenseMap API
#'
#' @return An \code{osem_measurements data.frame} containing the
#'   requested measurements
#'
#' @export
#' @seealso \href{https://docs.opensensemap.org/#api-Measurements-getDataMulti}{openSenseMap API documentation (web)}
#' @seealso \code{\link{osem_boxes}}
osem_measurements = function (x, ...) UseMethod('osem_measurements')

# ==============================================================================
#
#' @describeIn osem_measurements Get measurements from \strong{all} senseBoxes.
#' @export
#' @examples
#' # get measurements from all boxes
#' \dontrun{
#' osem_measurements('PM2.5')
#' }
#'
osem_measurements.default = function (x, ...) {
  bbox = structure(c(-180, -90, 180, 90), class = 'bbox')
  osem_measurements(bbox, x, ...)
}

# ==============================================================================
#
#' @describeIn osem_measurements Get measurements by a spatial filter.
#' @export
#' @examples
#' # get measurements from sensors within a bounding box
#' bbox = structure(c(7, 51, 8, 52), class = 'bbox')
#' osem_measurements(bbox, 'Temperatur')
#'
#' points = sf::st_multipoint(matrix(c(7, 8, 51, 52), 2, 2))
#' bbox2 = sf::st_bbox(points)
#' osem_measurements(bbox2, 'Temperatur', exposure = 'outdoor')
#'
osem_measurements.bbox = function (x, phenomenon, exposure = NA,
                                   from = NA, to = NA, columns = NA,
                                   ...,
                                   endpoint = 'https://api.opensensemap.org') {
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
#' # get measurements from a set of boxes
#' b = osem_boxes(grouptag = 'ifgi')
#' osem_measurements(b, phenomenon = 'Temperatur')
#'
#' # ...or a single box
#' b = osem_box('593bcd656ccf3b0011791f5a')
#' osem_measurements(b, phenomenon = 'Temperatur')
#'
osem_measurements.sensebox = function (x, phenomenon, exposure = NA,
                                       from = NA, to = NA, columns = NA,
                                       ...,
                                       endpoint = 'https://api.opensensemap.org') {
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
  if (is.null(params$phenomenon) | is.na(params$phenomenon))
    stop('Parameter "phenomenon" is required')

  if (!is.na(params$from) && is.na(params$to))
    stop('specify "from" only together with "to"')

  if (
    (!is.null(params$bbox) && !is.null(params$boxes)) ||
    (is.null(params$bbox) && is.null(params$boxes))
  ) stop('Specify either "bbox" or "boxes"')

  query = list(endpoint = params$endpoint, phenomenon = params$phenomenon)

  if (!is.null(params$boxes))  query$boxId = paste(params$boxes$X_id, collapse = ',')
  if (!is.null(params$bbox))   query$bbox = paste(params$bbox, collapse = ',')

  if (!is.na(params$from) && !is.na(params$to)) {
    parse_dateparams(params$from, params$to) # only for validation sideeffect
    query$`from-date` = utc_date(params$from)
    query$`to-date` = utc_date(params$to)
  }

  if (!is.na(params$exposure)) query$exposure = params$exposure
  if (!is.na(params$columns))
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
  from = query$from
  to = query$to
  dates = list()
  while (from < to) {
    in31days = from + as.difftime(31, units = 'days')
    dates = append(dates, list(list(from = from, to = min(in31days, to))))
    from = in31days + as.difftime(1, units = 'secs')
  }

  # use the dates as pages for multiple requests
  lapply(dates, function(page) {
    query$`from-date` = date_as_isostring(page$from)
    query$`to-date` = date_as_isostring(page$to)
    res = do.call(get_measurements_, query)
    cat(paste(query$`from-date`, query$`to-date`, sep = ' - '))
    cat('\n')
    res
  }) %>%
    dplyr::bind_rows()
}
