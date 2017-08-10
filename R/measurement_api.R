osem_measurements = function (x, ...) UseMethod('osem_measurements')

osem_measurements.default = function (phenomenon, ...) {
  bbox = structure(c(-180, -90, 180, 90), class = 'bbox')
  osem_measurements(bbox, phenomenon, ...)
}

# /boxes/data?bbox=
osem_measurements.bbox = function (bbox, phenomenon, exposure = NA,
                                   from = NA, to = NA,
                                   columns = NA,
                                   endpoint = 'https://api.opensensemap.org') {
  query = parse_get_measurements_params(as.list(environment()))
  do.call(get_measurements_, query)
}

# /boxes/data?boxId=1,2,3,4
osem_measurements.sensebox = function (boxes, phenomenon, exposure = NA,
                                       from = NA, to = NA,
                                       columns = NA,
                                       endpoint = 'https://api.opensensemap.org') {
  query = parse_get_measurements_params(as.list(environment()))
  do.call(get_measurements_, query)
}

parse_get_measurements_params = function (params) {
  if (is.null(params$phenomenon) | is.na(params$phenomenon))
    stop('Parameter "phenomenon" is required')
  if (!is.na(params$from) && is.na(params$to)) stop('specify "from" only together with "to"')
  if (
    (!is.null(params$bbox) && !is.null(params$boxes)) ||
    (is.null(params$bbox) && is.null(params$boxes))
  ) stop('Specify either "bbox" or "boxes"')

  query = list(endpoint = params$endpoint, phenomenon = params$phenomenon)

  if (!is.null(params$boxes))  query$boxIds = paste(params$boxes$X_id, collapse = ',')
  if (!is.null(params$bbox))   query$bbox = paste(params$bbox, collapse = ',')

  if (!is.na(params$from))     query$`from-date` = date_as_isostring(params$from)
  if (!is.na(params$to))       query$`to-date` = date_as_isostring(params$to)
  if (!is.na(params$exposure)) query$exposure = params$exposure
  if (!is.na(params$columns))  query$columns = paste(params$columns, collapse = ',')

  query
}
