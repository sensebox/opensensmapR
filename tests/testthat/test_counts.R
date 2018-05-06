source('testhelpers.R')
context('counts')

test_that('counts can be retrieved as a list of numbers', {
  check_api()

  counts = osem_counts()

  expect_true(is.list(counts))
  expect_true(is.numeric(unlist(counts)))
  expect_length(counts, 3)
})
