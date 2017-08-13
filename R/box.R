# ==============================================================================
#
#' Get a set of senseBoxes from the openSenseMap
#'
#' Boxes can be selected by a set of filters.
#' Note that some filters do not work together:
#' \enumerate{
#'   \item \code{phenomenon} can only be applied together with \code{date} or
#'     \code{from / to}
#'   \item \code{date} and \code{from / to} cannot be specified together
#' }
#'
#' @param exposure Only return boxes with the given exposure ('indoor', 'outdoor', 'mobile')
#' @param model Only return boxes with the given model
#' @param grouptag Only return boxes with the given grouptag
#' @param date Only return boxes that were measuring within ±4 hours of the given time
#' @param from Only return boxes that were measuring later than this time
#' @param to Only return boxes that were measuring earlier than this time
#' @param phenomenon Only return boxes that measured the given phenomenon in the
#'   time interval as specified through \code{date} or \code{from / to}
#' @param endpoint The URL of the openSenseMap API instance
#' @return A \code{sensebox data.frame} containing a box in each row
#'
#' @seealso \href{https://docs.opensensemap.org/#api-Measurements-findAllBoxes}{openSenseMap API documentation (web)}
#' @seealso \code{\link{osem_phenomena}}
#' @export
#' @examples
#' # TODO
osem_boxes = function (exposure = NA, model = NA, grouptag = NA,
                      date = NA, from = NA, to = NA, phenomenon = NA,
                      endpoint = 'https://api.opensensemap.org') {

  # error, if phenomenon, but no time given
  if (!is.na(phenomenon) && is.na(date) && is.na(to) && is.na(from))
    stop('Parameter "phenomenon" can only be used together with "date" or "from"/"to"')

  # error, if date and from/to given
  if (!is.na(date) && (!is.na(to) || !is.na(from)))
    stop('Parameter "date" cannot be used together with "from"/"to"')

  # error, if only one of from/to given
  if (
    (!is.na(to) && is.na(from)) ||
    (is.na(to) && !is.na(from))
  ) {
   stop('Parameter "from"/"to" must be used together')
  }

  query = list(endpoint = endpoint)
  if (!is.na(exposure)) query$exposure = exposure
  if (!is.na(model)) query$model = model
  if (!is.na(grouptag)) query$grouptag = grouptag
  if (!is.na(phenomenon)) query$phenomenon = phenomenon

  if (!is.na(to) && !is.na(from)) {
    # error, if from is after to
    # convert dates to commaseparated UTC ISOdates
    query$date = parse_dateparams(from, to) %>% paste(collapse = ',')

  } else if (!is.na(date)) {
    query$date = utc_date(date) %>% date_as_isostring()
  }

  do.call(get_boxes_, query)
}

# ==============================================================================
#
#' Get a single senseBox by its ID
#'
#' @param boxId A string containing a senseBox ID
#' @param endpoint The URL of the openSenseMap API instance
#' @return A \code{sensebox data.frame} containing a box in each row
#'
#' @seealso \href{https://docs.opensensemap.org/#api-Measurements-findAllBoxes}{openSenseMap API documentation (web)}
#' @seealso \code{\link{osem_phenomena}}
#' @export
#' @examples
#' # TODO
osem_box = function (boxId, endpoint = 'https://api.opensensemap.org') {
  get_box_(boxId, endpoint = endpoint)
}

# ==============================================================================
#
#' Construct a senseBox data.frame
#'
#' Parses the fields of a \code{/boxes} response from the openSenseMap API
#'
#' @param boxdata A named \code{list} containing the data for a box
#' @return A \code{data.frame} with an attached class \code{sensebox}.
#' @noRd
parse_senseboxdata = function (boxdata) {
  # extract nested lists for later use & clean them from the list
  # to allow a simple data.frame structure
  sensors = boxdata$sensors
  location = boxdata$loc
  boxdata[c('loc', 'sensors', 'image', 'boxType')] <- NULL
  thebox = as.data.frame(boxdata, stringsAsFactors = F)

  # parse timestamps (updatedAt might be not defined)
  thebox$createdAt = as.POSIXct(strptime(thebox$createdAt, format='%FT%T', tz = 'GMT'))
  if (!is.null(thebox$updatedAt))
    thebox$updatedAt = as.POSIXct(strptime(thebox$updatedAt, format='%FT%T', tz = 'GMT'))

  # extract metadata from sensors
  thebox$phenomena = list(unlist(lapply(sensors, function(s) { s$title })))
  # FIXME: if one sensor has NA, max() returns bullshit
  thebox$lastMeasurement = max(lapply(sensors, function(s) {
    if (!is.null(s$lastMeasurement))
      as.POSIXct(strptime(s$lastMeasurement$createdAt, format = '%FT%T', tz = 'GMT'))
    else
      NA
  })[[1]])

  # extract coordinates & transform to simple feature object
  thebox$lon = location[[1]]$geometry$coordinates[[1]]
  thebox$lat = location[[1]]$geometry$coordinates[[2]]
  if (length(location[[1]]$geometry$coordinates) == 3)
    thebox$height = location[[1]]$geometry$coordinates[[3]]

  # attach a custom class for methods
  class(thebox) = c('sensebox', class(thebox))
  thebox
}