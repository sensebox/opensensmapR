context("box")

check_api <- function() {
  code <- NA
  try(code <- httr::status_code(httr::GET(osem_endpoint())))
  if (is.na(code)) skip("API not available")
}

try({
  boxes <- osem_boxes()
})

test_that("a box can be converted to sf object", {
  check_api()
  
  box <- osem_box(boxes$X_id[[1]])
  box_sf <- sf::st_as_sf(box)
  
  expect_true(sf::st_is_simple(box_sf))
  expect_true("sf" %in% class(box_sf))
})

test_that("a box converted to sf object keeps all attributes", {
  check_api()
  
  skip("FIXME")
  
  box <- osem_box(boxes$X_id[[1]])
  box_sf <- sf::st_as_sf(box)
  
  expect_true(all(names(box) %in% names(box_sf)))
})
