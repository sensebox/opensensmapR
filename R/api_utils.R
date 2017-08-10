osem_remote_error = function (response) {
  if (!is.null(response$code)) stop(response$message)

  invisible(response)
}

date_as_isostring = function (date) {
  # as_datetime is required so UTC times are always returned
  # TODO: check if we can get along without lubridate dependency?
  lubridate::as_datetime(date) %>% format.Date(format = '%FT%TZ')
}
