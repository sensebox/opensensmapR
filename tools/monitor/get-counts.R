library(magrittr)
library(opensensmapr)

if (is.null(as.list(environment())$osem_counts_ts))
  osem_counts_ts = data.frame()

osem_counts_ts = osem_counts() %>%
  list(time = Sys.time()) %>%
  as.data.frame() %>%
  rbind(osem_counts_ts)
