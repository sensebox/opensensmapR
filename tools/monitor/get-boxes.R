library(magrittr)
library(opensensmapr)
library(sf)

if (is.null(as.list(environment())$osem_boxes_ts))
  osem_boxes_ts = data.frame()

b = osem_boxes()

# for $`active` computations
diffNow = (opensensmapr:::utc_date(Sys.time()) - b$lastMeasurement) %>% as.numeric(unit='hours')
neverActive = b[is.na(b$lastMeasurement), ] %>% nrow()

# only keep aggregated data
b_agg = data.frame(time = Sys.time(), boxcount = nrow(b))
b_agg$model = b$model %>% table() %>% as.list() %>% list()
b_agg$exposure = b$exposure %>% table() %>% as.list() %>% list()
b_agg$geometry = b %>% osem_as_sf() %>% st_geometry() %>% list()
b_agg$phenomena = b %>% osem_phenomena() %>% list()

b_agg$active = list(
  'never' = neverActive,
  '1h' = nrow(b[diffNow <= 1, ]) - neverActive,
  '1d' = nrow(b[diffNow <= 24, ]) - neverActive,
  '30d' = nrow(b[diffNow <= 720, ]) - neverActive,
  '365d' = nrow(b[diffNow <= 8760, ]) - neverActive
) %>% list()

# combine with existing time series
osem_boxes_ts = rbind(b_agg, osem_boxes_ts)

# cleanup
rm(b)
rm(b_agg)
