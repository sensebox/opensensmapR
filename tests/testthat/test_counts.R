context("counts")

check_api <- function() {
  skip_on_cran()

  code <- NA
  try(code <- httr::status_code(httr::GET(osem_endpoint())))
  if (is.na(code)) skip("API not available")
}

test_that("counts can be retrieved as a list of numbers", {
  check_api()

  counts <- osem_counts()

  expect_true(is.list(counts))
  expect_true(is.numeric(unlist(counts)))
  expect_length(counts, 3)
})
