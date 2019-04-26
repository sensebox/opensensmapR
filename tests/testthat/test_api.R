context('API error handling')

test_that('unavailable API yields informative error message', {
  expect_error({
    osem_boxes(endpoint = 'example.zip')
  }, 'The API at example.zip is currently not available')
})
