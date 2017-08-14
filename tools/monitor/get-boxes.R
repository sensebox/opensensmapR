library(magrittr)
library(opensensmapr)
library(sf)

if (is.null(as.list(environment())$osem_boxes_ts))
  osem_boxes_ts = data.frame()

b = osem_boxes()

# only keep aggregated data
b_agg = data.frame(time = Sys.time(), boxcount = nrow(b))
b_agg$model = b$model %>% table() %>% as.list() %>% list()
b_agg$exposure = b$exposure %>% table() %>% as.list() %>% list()
b_agg$geometry = b %>% osem_as_sf() %>% st_geometry() %>% list()
b_agg$phenomena = b %>% osem_phenomena() %>% list()

# combine with existing time series
osem_boxes_ts = rbind(b_agg, osem_boxes_ts)

# cleanup
rm(b)
rm(b_agg)
