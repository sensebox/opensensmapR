# parses from/to params for get_measurements_ and get_boxes_
parse_dateparams = function (from, to) {
  from = date_as_utc(from)
  to = date_as_utc(to)
  if (from - to > 0) stop('"from" must be earlier than "to"')
  c(date_as_isostring(from), date_as_isostring(to))
}

# NOTE: cannot handle mixed vectors of POSIXlt and POSIXct
date_as_utc = function (date) {
  time = as.POSIXct(date)
  attr(time, 'tzone') = 'UTC'
  time
}

# NOTE: cannot handle mixed vectors of POSIXlt and POSIXct
date_as_isostring = function (date) format.Date(date, format = '%FT%TZ')

isostring_as_date = function (x) as.POSIXct(strptime(x, format = '%FT%T', tz = 'GMT'))

#' Checks for an interactive session using interactive() and a knitr process in
#' the callstack. See https://stackoverflow.com/a/33108841
#'
#' @noRd
is_non_interactive = function () {
  ff = sapply(sys.calls(), function(f) as.character(f[1]))
  any(ff %in% c('knit2html', 'render')) || !interactive()
}

#' custom recursive lapply with better handling of NULL values
#' from https://stackoverflow.com/a/38950304
#' @noRd
recursive_lapply = function(x, fn) {
  if (is.list(x))
    lapply(x, recursive_lapply, fn)
  else
    fn(x)
}
