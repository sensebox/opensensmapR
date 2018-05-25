## ----cache---------------------------------------------------------------
b = osem_boxes(cache = tempdir())
list.files(tempdir(), pattern = 'osemcache\\..*\\.rds')

# the next identical request will hit the cache only!
b = osem_boxes(cache = tempdir())

# requests without the cache parameter will still be performed normally
b = osem_boxes()

## ----cache_custom--------------------------------------------------------
cacheDir = getwd() # current working directory
b = osem_boxes(cache = cacheDir)

# the next identical request will hit the cache only!
b = osem_boxes(cache = cacheDir)

## ----clearcache----------------------------------------------------------
osem_clear_cache() # clears default cache
osem_clear_cache(getwd()) # clears a custom cache

## ----setup, results='hide'-----------------------------------------------
# this section requires:
library(opensensmapr)
library(jsonlite)
library(readr)

# first get our example data:
boxes = osem_boxes(grouptag = 'ifgi')
measurements = osem_measurements(boxes, phenomenon = 'PM10')

## ----serialize_json------------------------------------------------------
# serializing senseBoxes to JSON, and loading from file again:
write(jsonlite::serializeJSON(measurements), 'boxes.json')
boxes_from_file = jsonlite::unserializeJSON(readr::read_file('boxes.json'))

## ----serialize_attrs-----------------------------------------------------
# note the toJSON call
write(jsonlite::toJSON(measurements), 'boxes_bad.json')
boxes_without_attrs = jsonlite::fromJSON('boxes_bad.json')

boxes_with_attrs = osem_as_sensebox(boxes_without_attrs)
class(boxes_with_attrs)

## ----osem_offline--------------------------------------------------------
# offline logic
osem_offline = function (func, file, format='rds', ...) {
  # deserialize if file exists, otherwise download and serialize
  if (file.exists(file)) {
    if (format == 'json')
      jsonlite::unserializeJSON(readr::read_file(file))
    else
      readRDS(file)
  } else {
    data = func(...)
    if (format == 'json')
      write(jsonlite::serializeJSON(data), file = file)
    else
      saveRDS(data, file)
    data
  }
}

# wrappers for each download function
osem_measurements_offline = function (file, ...) {
  osem_offline(opensensmapr::osem_measurements, file, ...)
}
osem_boxes_offline = function (file, ...) {
  osem_offline(opensensmapr::osem_boxes, file, ...)
}
osem_box_offline = function (file, ...) {
  osem_offline(opensensmapr::osem_box, file, ...)
}
osem_counts_offline = function (file, ...) {
  osem_offline(opensensmapr::osem_counts, file, ...)
}

## ----test----------------------------------------------------------------
# first run; will download and save to disk
b1 = osem_boxes_offline('mobileboxes.rds', exposure='mobile')

# consecutive runs; will read from disk
b2 = osem_boxes_offline('mobileboxes.rds', exposure='mobile')
class(b1) == class(b2)

# we can even omit the arguments now (though thats not really the point here)
b3 = osem_boxes_offline('mobileboxes.rds')
nrow(b1) == nrow(b3)

# verify that the custom sensebox methods are still working
summary(b2)
plot(b3)

## ----cleanup, results='hide'---------------------------------------------
file.remove('mobileboxes.rds', 'boxes_bad.json', 'boxes.json', 'measurements.rds')

