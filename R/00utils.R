# parses from/to params for get_measurements_ and get_boxes_
parse_dateparams = function (from, to) {
  from = utc_date(from)
  to = utc_date(to)
  if (from - to > 0) stop('"from" must be earlier than "to"')
  c(date_as_isostring(from), date_as_isostring(to))
}

# NOTE: cannot handle mixed vectors of POSIXlt and POSIXct
utc_date = function (date) {
  time = as.POSIXct(date)
  attr(time, 'tzone') = 'UTC'
  time
}

# NOTE: cannot handle mixed vectors of POSIXlt and POSIXct
date_as_isostring = function (date) format.Date(date, format = '%FT%TZ')

#' Checks for an interactive session using interactive() and a knitr process in
#' the callstack. See https://stackoverflow.com/a/33108841
#'
#' @noRd
is_non_interactive = function () {
  ff = sapply(sys.calls(), function(f) as.character(f[1]))
  any(ff %in% c('knit2html', 'render')) || !interactive()
}
