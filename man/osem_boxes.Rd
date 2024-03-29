% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/box.R
\name{osem_boxes}
\alias{osem_boxes}
\title{Get a set of senseBoxes from the openSenseMap}
\usage{
osem_boxes(
  exposure = NA,
  model = NA,
  grouptag = NA,
  date = NA,
  from = NA,
  to = NA,
  phenomenon = NA,
  bbox = NA,
  endpoint = osem_endpoint(),
  progress = TRUE,
  cache = NA
)
}
\arguments{
\item{exposure}{Only return boxes with the given exposure ('indoor', 'outdoor', 'mobile')}

\item{model}{Only return boxes with the given model}

\item{grouptag}{Only return boxes with the given grouptag}

\item{date}{Only return boxes that were measuring within ±4 hours of the given time}

\item{from}{Only return boxes that were measuring later than this time}

\item{to}{Only return boxes that were measuring earlier than this time}

\item{phenomenon}{Only return boxes that measured the given phenomenon in the
time interval as specified through \code{date} or \code{from / to}}

\item{bbox}{Only return boxes that are within the given boundingbox, 
vector of 4 WGS84 coordinates. 
Order is: longitude southwest, latitude southwest, longitude northeast, latitude northeast. 
Minimal and maximal values are: -180, 180 for longitude and -90, 90 for latitude.}

\item{endpoint}{The URL of the openSenseMap API instance}

\item{progress}{Whether to print download progress information, defaults to \code{TRUE}}

\item{cache}{Whether to cache the result, defaults to false.
If a valid path to a directory is given, the response will be cached there.
Subsequent identical requests will return the cached data instead.}
}
\value{
A \code{sensebox data.frame} containing a box in each row
}
\description{
Boxes can be selected by a set of filters.
Note that some filters do not work together:
\enumerate{
  \item \code{phenomenon} can only be applied together with \code{date} or
    \code{from / to}
  \item \code{date} and \code{from / to} cannot be specified together
}
}
\examples{

\dontrun{
  # get *all* boxes available on the API
  b = osem_boxes()

  # get all boxes with grouptag 'ifgi' that are placed outdoors
  b = osem_boxes(grouptag = 'ifgi', exposure = 'outdoor')

  # get all boxes with model 'luftdaten_sds011_dht22'
  b = osem_boxes(grouptag = 'ifgi')

  # get all boxes that have measured PM2.5 in the last 4 hours
  b = osem_boxes(date = Sys.time(), phenomenon = 'PM2.5')

  # get all boxes that have measured PM2.5 between Jan & Feb 2018
  library(lubridate)
  b = osem_boxes(
    from = date('2018-01-01'),
    to = date('2018-02-01'),
    phenomenon = 'PM2.5'
  )

  # get all boxes from a custom (selfhosted) openSenseMap API
  b = osem_box(endpoint = 'http://api.my-custom-osem.com')

  # get all boxes and cache the response, in order to provide
  # reproducible results in the future. Also useful for development
  # to avoid repeated loading times!
  b = osem_boxes(cache = getwd())
  b = osem_boxes(cache = getwd())

  # get *all* boxes available on the API, without showing download progress
  b = osem_boxes(progress = FALSE)
}
}
\seealso{
\href{https://docs.opensensemap.org/#api-Measurements-findAllBoxes}{openSenseMap API documentation (web)}

\code{\link{osem_phenomena}}

\code{\link{osem_box}}

\code{\link{osem_clear_cache}}
}
