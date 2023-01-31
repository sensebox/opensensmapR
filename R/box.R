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
#' @param bbox Only return boxes that are within the given boundingbox, 
#'   vector of 4 WGS84 coordinates. 
#'   Order is: longitude southwest, latitude southwest, longitude northeast, latitude northeast. 
#'   Minimal and maximal values are: -180, 180 for longitude and -90, 90 for latitude.
#' @param endpoint The URL of the openSenseMap API instance
#' @param progress Whether to print download progress information, defaults to \code{TRUE}
#' @param cache Whether to cache the result, defaults to false.
#'   If a valid path to a directory is given, the response will be cached there.
#'   Subsequent identical requests will return the cached data instead.
#' @return A \code{sensebox data.frame} containing a box in each row
#'
#' @seealso \href{https://docs.opensensemap.org/#api-Measurements-findAllBoxes}{openSenseMap API documentation (web)}
#' @seealso \code{\link{osem_phenomena}}
#' @seealso \code{\link{osem_box}}
#' @seealso \code{\link{osem_clear_cache}}
#'
#' @export
#' @examples
#'
#' \donttest{
#'   # get *all* boxes available on the API
#'   b = osem_boxes()
#'
#'   # get all boxes with grouptag 'ifgi' that are placed outdoors
#'   b = osem_boxes(grouptag = 'ifgi', exposure = 'outdoor')
#'
#'   # get all boxes with model 'luftdaten_sds011_dht22'
#'   b = osem_boxes(grouptag = 'ifgi')
#'
#'   # get all boxes that have measured PM2.5 in the last 4 hours
#'   b = osem_boxes(date = Sys.time(), phenomenon = 'PM2.5')
#'
#'   # get all boxes that have measured PM2.5 between Jan & Feb 2018
#'   library(lubridate)
#'   b = osem_boxes(
#'     from = date('2018-01-01'),
#'     to = date('2018-02-01'),
#'     phenomenon = 'PM2.5'
#'   )
#'
#'   # get all boxes from a custom (selfhosted) openSenseMap API
#'   b = osem_box(endpoint = 'http://api.my-custom-osem.com')
#'
#'   # get all boxes and cache the response, in order to provide
#'   # reproducible results in the future. Also useful for development
#'   # to avoid repeated loading times!
#'   b = osem_boxes(cache = getwd())
#'   b = osem_boxes(cache = getwd())
#'
#'   # get *all* boxes available on the API, without showing download progress
#'   b = osem_boxes(progress = FALSE)
#' }
osem_boxes = function (exposure = NA, model = NA, grouptag = NA,
                      date = NA, from = NA, to = NA, phenomenon = NA, 
                      bbox = NA,
                      endpoint = osem_endpoint(),
                      progress = TRUE,
                      cache = NA) {

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

  query = list(endpoint = endpoint, progress = progress, cache = cache)
  if (!is.na(exposure)) query$exposure = exposure
  if (!is.na(model)) query$model = model
  if (!is.na(grouptag)) query$grouptag = grouptag
  if (!is.na(phenomenon)) query$phenomenon = phenomenon
  if (all(!is.na(bbox))) query$bbox = paste(bbox, collapse = ', ')

  if (!is.na(to) && !is.na(from))
    query$date = parse_dateparams(from, to) %>% paste(collapse = ',')
  else if (!is.na(date))
    query$date = date_as_utc(date) %>% date_as_isostring()


  do.call(get_boxes_, query)
}

# ==============================================================================
#
#' Get a single senseBox by its ID
#'
#' @param boxId A string containing a senseBox ID
#' @param endpoint The URL of the openSenseMap API instance
#' @param cache Whether to cache the result, defaults to false.
#'   If a valid path to a directory is given, the response will be cached there. Subsequent identical requests will return the cached data instead.
#' @return A \code{sensebox data.frame} containing a box in each row
#'
#' @seealso \href{https://docs.opensensemap.org/#api-Measurements-findAllBoxes}{openSenseMap API documentation (web)}
#' @seealso \code{\link{osem_phenomena}}
#' @seealso \code{\link{osem_boxes}}
#' @seealso \code{\link{osem_clear_cache}}
#' @export
#' @examples
#' \donttest{
#'   # get a specific box by ID
#'   b = osem_box('57000b8745fd40c8196ad04c')
#'
#'   # get a specific box by ID from a custom (selfhosted) openSenseMap API
#'   b = osem_box('51030b8725fd30c2196277da', 'http://api.my-custom-osem.com')
#'
#'   # get a specific box by ID and cache the response, in order to provide
#'   # reproducible results in the future.
#'   b = osem_box('51030b8725fd30c2196277da', cache = tempdir())
#' }
osem_box = function (boxId, endpoint = osem_endpoint(), cache = NA) {
  get_box_(boxId, endpoint = endpoint, cache = cache)
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
  location = boxdata$currentLocation
  lastMeasurement = boxdata$lastMeasurementAt # rename for backwards compat < 0.5.1
  grouptags = boxdata$grouptag
  boxdata[c(
    'loc', 'locations', 'currentLocation', 'sensors', 'image', 'boxType', 'lastMeasurementAt', 'grouptag'
  )] = NULL
  thebox = as.data.frame(boxdata, stringsAsFactors = F)

  # parse timestamps (updatedAt might be not defined)
  thebox$createdAt = isostring_as_date(thebox$createdAt)
  if (!is.null(thebox$updatedAt))
    thebox$updatedAt = isostring_as_date(thebox$updatedAt)
  if (!is.null(lastMeasurement))
    thebox$lastMeasurement = isostring_as_date(lastMeasurement)

  # add empty sensortype to sensors without type
  if(!('sensorType' %in% names(sensors[[1]]))) {
    sensors[[1]]$sensorType <- NA
  }

  # create a dataframe of sensors
  thebox$sensors = sensors %>%
    recursive_lapply(function (x) if (is.null(x)) NA else x) %>% # replace NULLs with NA
    lapply(as.data.frame, stringsAsFactors = F) %>%
    dplyr::bind_rows(.) %>%
    dplyr::select(phenomenon = title, id = X_id, unit, sensor = sensorType) %>%
    list

  # extract metadata from sensors
  thebox$phenomena = sensors %>%
    stats::setNames(lapply(., function (s) s$`_id`)) %>%
    lapply(function(s) s$title) %>%
    unlist %>% list # convert to vector

  # extract coordinates & transform to simple feature object
  thebox$lon = location$coordinates[[1]]
  thebox$lat = location$coordinates[[2]]
  thebox$locationtimestamp = isostring_as_date(location$timestamp)
  if (length(location$coordinates) == 3)
    thebox$height = location$coordinates[[3]]

  # extract grouptag(s) from box 
  if (length(grouptags) == 0)
    thebox$grouptag = NULL
  if (length(grouptags) > 0) {
    # if box does not have grouptag dont set attribute
    if(grouptags[[1]] == '') {
      thebox$grouptag = NULL
    }
    else {
      thebox$grouptag = grouptags[[1]]
    }
  }
  if (length(grouptags) > 1)
    thebox$grouptag2 = grouptags[[2]]
  if (length(grouptags)  > 2)
    thebox$grouptag3 = grouptags[[3]]

  # attach a custom class for methods
  osem_as_sensebox(thebox)
}
