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

get_phenomena = function (x, ...) UseMethod('get_phenomena')
get_phenomena.default = function (x, ...) stop('not implemented')
get_phenomena.sensebox = function (x, ...) {
  # FIXME: only returns first box for get_boxes!
  x$phenomena[[1]]
}
