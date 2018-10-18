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
  response = osem_get_resource(endpoint, path = c('boxes'), ...)

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

get_box_ = function (boxId, endpoint, ...) {
  osem_get_resource(endpoint, path = c('boxes', boxId), ..., progress = FALSE) %>%
    parse_senseboxdata()
}

parse_measurement_csv = function (resText) {
  # parse the CSV response manually & mute readr
  suppressWarnings({
    result = readr::read_csv(resText, col_types = readr::cols(
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

get_measurements_ = function (..., endpoint) {
  osem_get_resource(endpoint, c('boxes', 'data'), ..., type = 'text') %>%
    parse_measurement_csv
}

get_stats_ = function (endpoint, cache) {
  result = osem_get_resource(endpoint, path = c('stats'), progress = FALSE, cache = cache)
  names(result) = c('boxes', 'measurements', 'measurements_per_minute')
  result
}

#' Get any resource from openSenseMap API, possibly cache the response
#'
#' @param host API host
#' @param path resource URL
#' @param ... All other parameters interpreted as request query parameters
#' @param type Passed to httr; 'parsed' to return an R object from the response, 'text for a raw response
#' @param progress Boolean whether to print download progress information
#' @param cache Optional path to a directory were responses will be cached. If not NA, no requests will be made when a request for the given is already cached.
#' @return Result of a Request to openSenseMap API
#' @noRd
osem_get_resource = function (host, path, ..., type = 'parsed', progress = T, cache = NA) {
  query = list(...)
  if (!is.na(cache)) {
    filename = osem_cache_filename(path, query, host) %>% paste(cache, ., sep = '/')
    if (file.exists(filename))
      return(readRDS(filename))
  }

  res = osem_request_(host, path, query, type, progress)
  if (!is.na(cache)) saveRDS(res, filename)
  res
}

osem_cache_filename = function (path, query = list(), host = osem_endpoint()) {
  httr::modify_url(url = host, path = path, query = query) %>%
    digest::digest(algo = 'sha1') %>%
    paste('osemcache', ., 'rds', sep = '.')
}

#' Purge cached responses from the given cache directory
#'
#' @param location A path to the cache directory, defaults to the
#'   sessions' \code{tempdir()}
#' @return Boolean whether the deletion was successful
#'
#' @export
#' @examples
#' \donttest{
#'   osem_boxes(cache = tempdir())
#'   osem_clear_cache()
#'
#'   cachedir = paste(getwd(), 'osemcache', sep = '/')
#'   osem_boxes(cache = cachedir)
#'   osem_clear_cache(cachedir)
#' }
osem_clear_cache = function (location = tempdir()) {
  list.files(location, pattern = 'osemcache\\..*\\.rds') %>%
    lapply(function (f) file.remove(paste(location, f, sep = '/'))) %>%
    unlist() %>%
    all()
}

osem_request_ = function (host, path, query = list(), type = 'parsed', progress = TRUE) {
  progress = if (progress && !is_non_interactive()) httr::progress() else NULL
  res = httr::GET(host, progress, path = path, query = query)

  if (httr::http_error(res)) {
    content = httr::content(res, 'parsed', encoding = 'UTF-8')
    stop(if ('message' %in% names(content)) content$message else httr::status_code(res))
  }

  content = httr::content(res, type, encoding = 'UTF-8')
}
