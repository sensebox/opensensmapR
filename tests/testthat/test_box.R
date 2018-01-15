context("box")

check_api <- function() {
  skip_on_cran()

  code <- NA
  try(code <- httr::status_code(httr::GET(osem_endpoint())))
  if (is.na(code)) skip("API not available")
}

try({
  boxes <- osem_boxes()
})

test_that("a single box can be retrieved by ID", {
  check_api()

  box <- osem_box(boxes$X_id[[1]])

  expect_true("sensebox" %in% class(box))
  expect_true("data.frame" %in% class(box))
  expect_true(nrow(box) == 1)
  expect_true(box$X_id == boxes$X_id[[1]])
})


test_that("[.sensebox maintains attributes", {
  check_api()

  expect_true(all(attributes(boxes[1:nrow(boxes), ]) %in% attributes(boxes)))
})
