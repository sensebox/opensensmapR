# does not actually get called by the user. ... contains all the query parameters.
# the proxy is just for parameter autocompletion, filtering out the endpoint
get_boxes_ = function (..., endpoint) {
  response = httr::GET(endpoint, path = c('boxes'), query = list(...)) %>%
    httr::content() %>%
    osem_remote_error()

  if (length(response) == 0) {
    warning('no boxes found for this query')
    return(response)
  }

  # parse each list element as sensebox & combine them to a single data.frame
  #
  # bind_rows() kills the attributes and classes of sf_sfc column, and warns
  # about that. see https://github.com/r-spatial/sf/issues/49
  # we readd the attributes manually afterwards, so we can ignore the warnings.
  # rbind() wouldn't have this problem, but would be far slower and con't
  # handle missing columns, so this seems like a good tradeoff..
  boxesList = lapply(response, parse_senseboxdata)
  suppressWarnings({ data = dplyr::bind_rows(boxesList) })
  data$geometry = sf::st_sfc(data$geometry, crs = 4326)
  #sf::st_geometry(data) = sf::st_sfc(data$geometry, crs = 4326)
  #sf::st_sf(data)

  data
}

get_box_ = function (..., endpoint) {
  httr::GET(endpoint, path = c('boxes', ...)) %>%
    httr::content() %>%
    osem_remote_error() %>%
    parse_senseboxdata()
}

get_measurements_ = function (..., endpoint) {
  httr::GET(endpoint, path = c('boxes', 'data'), query = list(...)) %>%
    httr::content() %>%
    osem_remote_error()
}

get_stats_ = function (endpoint) {
  result = httr::GET(endpoint, path = c('stats')) %>%
    httr::content() %>%
    osem_remote_error()

  names(result) = c('boxes', 'measurements', 'measurements_per_minute')
  result
}
