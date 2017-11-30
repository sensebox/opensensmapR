#' opensensmapr: Get sensor data from opensensemap.org
#'
#' The opensensmapr package provides functions for
#' \itemize{
#'   \item retrieval of senseBox metadata,
#'   \item retrieval of senseBox measurements,
#'   \item general statistics about the openSenseMap database.
#' }
#' Additionally, helper functions are provided to ease the integration with the
#' \code{\link{sf}} package for spatial analysis as well as \code{\link{deplyr}}
#' for general data handling.
#'
#' @section Retrieving senseBox metadata:
#' On the openSenseMap, measurements are provided by sensors which are assigned
#' to a sensor station ("senseBox").
#' A senseBox consists of a collection of sensors, a location (-history), an ID,
#' as well as metadata about its owner & placement.
#' senseBoxes can be retrieved either by ID, or as a collection with optional
#' filters on their metadata
#' \itemize{
#'   \item \code{\link{osem_box}}: Get metadata about a single box
#'     by its ID.
#'   \item \code{\link{osem_boxes}}: Get metadata about a all
#'     boxes. Optionally filtered by their attributes.
#' }
#'
#' The data is returned as a \code{\link{data.frame}} with the class
#' \code{sensebox} attached.
#' To help in getting an overview of the dataset additional functions are
#' implemented:
#' \itemize{
#'   \item \code{summary.sensebox()}: Aggregate the metadata about the given
#'     list of senseBoxes.
#'   \item \code{plot.sensebox()}: Shows the spatial distribution of the given
#'     list of senseBoxes on a map. Requires additional packages!
#'   \item \code{\link{osem_phenomena}}: Get a named list with
#'     counts of the measured phenomena of the given list of senseBoxes.
#' }
#'
#' @section Retrieving measurements:
#' Measurements can be retrieved through \code{\link{osem_measurements}} for a
#' given phenomenon only. A subset of measurements may be selected by
#'
#' \itemize{
#'   \item a list of senseBoxes, previously retrieved through
#'     \code{\link{osem_box}} or \code{\link{osem_boxes}}.
#'   \item a geographic bounding box, which can be generated with the
#'     \code{\link{sf}} package.
#'   \item a time frame
#'   \item a exposure type of the given box
#' }
#'
#' Data is returned as \code{data.frame} with the class \code{osem_measurements}.
#' The provided columns may
#'
#' @section Retrieving statistics:
#' Count statistics about the database are provided with \code{\link{osem_counts}}.
#'
#' @section Integration with other packages:
#' The package aims to be compatible with the tidyverse.
#' Helpers are implemented to ease the further usage of the retrieved data:
#'
#' \itemize{
#'   \item \code{\link{st_as_sf.sensebox}} & \code{\link{st_as_sf.osem_measurements}}:
#'     Transform the senseBoxes or measurements into an \code{\link{sf}}
#'     compatible format for spatial analysis.
#'   \item \code{filter.sensebox()} & \code{mutate.sensebox()}: for use with
#'     \code{\link{deplyr}}.
#' }
#'
#' @seealso Report bugs at \url{https://github.com/noerw/opensensmapR/issues}
#' @seealso openSenseMap API: \url{https://api.opensensemap.org/}
#' @seealso official openSenseMap API documentation: \url{https://docs.opensensemap.org/}
#' @docType package
#' @name opensensmapr
'_PACKAGE'

#' @importFrom graphics plot

#' @importFrom magrittr %>%
`%>%` = magrittr::`%>%`
