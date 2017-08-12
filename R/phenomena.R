# ==============================================================================
#
#' Get the counts of sensors for each observed phenomenon.
#'
#' @param boxes A \code{sensebox data.frame} of boxes
#' @return An \code{data.frame} containing the count of sensors observing a
#'   phenomenon per column.
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
#' # get the phenomena for a group of senseBoxes
#' osem_phenomena(
#'   osem_boxes(grouptag = 'ifgi', exposure = 'outdoor', date = Sys.time())
#' )
#'
#' # get phenomena with at least 10 sensors on opensensemap
#' phenoms = osem_phenomena(osem_boxes())
#' colnames(dplyr::select_if(phenoms, function(v) v > 9))
#'
osem_phenomena.sensebox = function (boxes) {
  Reduce(`c`, boxes$phenomena) %>% # get all the row contents in a single vector
    table() %>%                    # get count for each phenomenon
    t() %>%                        # transform the table to a df
    as.data.frame.matrix()
}
