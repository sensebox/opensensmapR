source('testhelpers.R')
context('box')

try({
  boxes = osem_boxes()
  box = osem_box(boxes$X_id[[1]])
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


test_that('[.sensebox maintains attributes', {
  check_api()

  expect_true(all(attributes(boxes[1:nrow(boxes), ]) %in% attributes(boxes)))
})

test_that("print.sensebox filters important attributes", {
  msg = capture.output({
    print(box)
  })
  expect_false(any(grepl('description', msg)), 'should filter attribute "description"')
})

test_that("summary.sensebox outputs all metrics", {
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
