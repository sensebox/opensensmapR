`%>%` = magrittr::`%>%`

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

osem_box = function (boxId, endpoint = 'https://api.opensensemap.org') {
  get_box_(boxId, endpoint = endpoint)
}
