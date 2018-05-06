# ==============================================================================
#  getters for the opensensemap API.
#  the awesome httr library does all the curling, query and response parsing.
#  for CSV responses (get_measurements) the readr package is a hidden dependency
# ==============================================================================

#' Get the default openSenseMap API endpoint
#' @export
#' @return A character string with the HTTP URL of the openSenseMap API
osem_endpoint = function() {
  'https://api.opensensemap.org'
}

get_boxes_ = function (..., endpoint) {
  response = osem_request_(endpoint, path = c('boxes'), ...)

  if (length(response) == 0) {
    warning('no senseBoxes found for this query')
    return(osem_as_sensebox(as.data.frame(response)))
  }

  # parse each list element as sensebox & combine them to a single data.frame
  boxesList = lapply(response, parse_senseboxdata)
  df = dplyr::bind_rows(boxesList)
  df$exposure = df$exposure %>% as.factor()
  df$model    = df$model %>% as.factor()
  if (!is.null(df$grouptag))
    df$grouptag = df$grouptag %>% as.factor()
  df
}

get_box_ = function (boxId, endpoint) {
  osem_request_(endpoint, path = c('boxes', boxId), progress = F) %>%
    parse_senseboxdata()
}

get_measurements_ = function (..., endpoint) {
  result = osem_request_(endpoint, c('boxes', 'data'), ..., type = 'text')

  # parse the CSV response manually & mute readr
  suppressWarnings({
    result = readr::read_csv(result, col_types = readr::cols(
      # factor as default would raise issues with concatenation of multiple requests
      .default  = readr::col_character(),
      createdAt = readr::col_datetime(),
      value  = readr::col_double(),
      lat    = readr::col_double(),
      lon    = readr::col_double(),
      height = readr::col_double()
    ))
  })

  osem_as_measurements(result)
}

get_stats_ = function (endpoint) {
  result = osem_request_(endpoint, path = c('stats'), progress = F)
  names(result) = c('boxes', 'measurements', 'measurements_per_minute')
  result
}

osem_request_ = function (host, path, ..., type = 'parsed', progress) {
  progress = if (progress && !is_non_interactive()) httr::progress() else NULL
  res = httr::GET(host, progress, path = path, query = list(...))

  if (httr::http_error(res)) {
    content = httr::content(res, 'parsed', encoding = 'UTF-8')
    stop(if ('message' %in% names(content)) content$message else httr::status_code(res))
  }

  content = httr::content(res, type, encoding = 'UTF-8')
}
