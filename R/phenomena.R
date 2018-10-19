# ==============================================================================
#
#' Get the counts of sensors for each observed phenomenon.
#'
#' @param boxes A \code{sensebox data.frame} of boxes
#' @return A named \code{list} containing the count of sensors observing a
#'   phenomenon per phenomenon
#' @export
osem_phenomena = function (boxes) UseMethod('osem_phenomena')

# ==============================================================================
#
#' @describeIn osem_phenomena Get counts of sensors observing each phenomenon
#'   from a set of senseBoxes.
#' @export
#' @seealso \code{\link{osem_boxes}}
#' @examples
#' # get the phenomena for a single senseBox
#' osem_phenomena(osem_box('593bcd656ccf3b0011791f5a'))
#'
#' \donttest{
#'   # get the phenomena for a group of senseBoxes
#'   osem_phenomena(
#'     osem_boxes(grouptag = 'ifgi', exposure = 'outdoor', date = Sys.time())
#'   )
#'
#'   # get phenomena with at least 30 sensors on opensensemap
#'   phenoms = osem_phenomena(osem_boxes())
#'   names(phenoms[phenoms > 29])
#' }
osem_phenomena.sensebox = function (boxes) {
  p = Reduce(`c`, boxes$phenomena) %>% # get all the row contents in a single vector
    table() %>%                    # get count for each phenomenon
    as.list()

  p[order(unlist(p), decreasing = T)]
}
