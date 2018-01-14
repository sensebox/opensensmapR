context("measurements")

check_api <- function() {
  code <- NA
  try(code <- httr::status_code(httr::GET(osem_endpoint())))
  if (is.na(code)) skip("API not available")
}

try({
  boxes <- osem_boxes()
 })

test_that("measurements of specific boxes can be retrieved for one phenomenon and returns a measurements data.frame", {
  check_api()
  
  # fix for subsetting
  class(boxes) <- c("data.frame")
  three_boxes <- boxes[1:3,]
  three_boxes <- osem_as_sensebox(three_boxes)
  phens <- names(osem_phenomena(three_boxes))
  
  measurements <- osem_measurements(x = three_boxes, phenomenon = phens[[1]])
  expect_true(is.data.frame(measurements))
  expect_true("osem_measurements" %in% class(measurements))
})
