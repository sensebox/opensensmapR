# opensensmapr changelog

### 2017-08-24: v0.2.1
- add labels to `osem_measurements` plots
- add last active counts to `tools/monitor`

#### fixes
- fix regression from #2 for requests without from/to

### 2017-08-23: v0.2.0
- add auto paging for `osem_measurements()`, allowing data retrieval for arbitrary time intervals (#2)
- improve plots for `osem_measurements` & `sensebox` (#1)
- add `sensorId` & `unit` colummn to `get_measurements()` output by default
- show download progress info, hide readr output
- shorten vignette `osem-intro`

#### breaking changes
- return all string columns of `get_measurements()` as factors
