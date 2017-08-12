# ==============================================================================
#  getters for the opensensemap API.
#  the awesome httr library does all the curling, query and response parsing.
#  for CSV responses (get_measurements) the readr package is a hidden dependency
# ==============================================================================

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
  boxesList = lapply(response, parse_senseboxdata)
  df = dplyr::bind_rows(boxesList)
  df$exposure = df$exposure %>% as.factor()
  df$model    = df$model %>% as.factor()
  df$grouptag = df$grouptag %>% as.factor()
  df
}

get_box_ = function (..., endpoint) {
  httr::GET(endpoint, path = c('boxes', ...)) %>%
    httr::content() %>%
    osem_remote_error() %>%
    parse_senseboxdata()
}

get_measurements_ = function (..., endpoint) {
  # FIXME: get rid of readr warnings
  result = httr::GET(endpoint, path = c('boxes', 'data'), query = list(...)) %>%
    httr::content(encoding = 'UTF-8') %>%
    osem_remote_error()

  class(result) = c('osem_measurements', class(result))
  result
}

get_stats_ = function (endpoint) {
  result = httr::GET(endpoint, path = c('stats')) %>%
    httr::content() %>%
    osem_remote_error()

  names(result) = c('boxes', 'measurements', 'measurements_per_minute')
  result
}
