library(dplyr)
library(magrittr)
library(opensensemap)

if (is.null(as.list(environment())$osem_counts_ts))
  osem_counts_ts = data.frame()

osem_counts_ts = osem_counts() %>%
  list(time = Sys.time()) %>%
  as.data.frame() %>%
  dplyr::bind_rows(osem_counts_ts)

