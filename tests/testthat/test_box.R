source('testhelpers.R')
context('box')

try({
  boxes = osem_boxes()
  box = osem_box('57000b8745fd40c8196ad04c')
})

test_that('a single box can be retrieved by ID', {
  check_api()

  box = osem_box(boxes$X_id[[1]])

  expect_true('sensebox' %in% class(box))
  expect_true('data.frame' %in% class(box))
  expect_true(nrow(box) == 1)
  expect_true(box$X_id == boxes$X_id[[1]])
  expect_silent(osem_box(boxes$X_id[[1]]))
})

test_that('unknown box throws', {
  check_api()

  expect_error(osem_box('asdf'))
  expect_error(osem_box('57000b8745fd40c800000000'), 'not found')
})

test_that('[.sensebox maintains attributes', {
  check_api()

  expect_true(all(attributes(boxes[1:nrow(boxes), ]) %in% attributes(boxes)))
})

test_that("print.sensebox filters important attributes for a single box", {
  msg = capture.output({
    print(box)
  })
  expect_false(any(grepl('description', msg)), 'should filter attribute "description"')
})

test_that("summary.sensebox outputs all metrics for a single box", {
  msg = capture.output({
    summary(box)
  })
  expect_true(any(grepl('sensors per box:', msg)))
  expect_true(any(grepl('oldest box:', msg)))
  expect_true(any(grepl('newest box:', msg)))
  expect_true(any(grepl('\\$last_measurement_within', msg)))
  expect_true(any(grepl('boxes by model:', msg)))
  expect_true(any(grepl('boxes by exposure:', msg)))
  expect_true(any(grepl('boxes total: 1', msg)))
})

test_that('requests can be cached', {
  check_api()

  osem_clear_cache(tempdir())
  expect_length(list.files(tempdir(), pattern = 'osemcache\\..*\\.rds'), 0)
  b = osem_box('57000b8745fd40c8196ad04c', cache = tempdir())

  cacheFile = paste(
    tempdir(),
    opensensmapr:::osem_cache_filename('/boxes/57000b8745fd40c8196ad04c'),
    sep = '/'
  )
  expect_true(file.exists(cacheFile))
  expect_length(list.files(tempdir(), pattern = 'osemcache\\..*\\.rds'), 1)

  # no download output (works only in interactive mode..)
  out = capture.output({
    b = osem_box('57000b8745fd40c8196ad04c', cache = tempdir())
  })
  expect_length(out, 0)
  expect_length(length(list.files(tempdir(), pattern = 'osemcache\\..*\\.rds')), 1)

  osem_clear_cache(tempdir())
  expect_false(file.exists(cacheFile))
  expect_length(list.files(tempdir(), pattern = 'osemcache\\..*\\.rds'), 0)
})
