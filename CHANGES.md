# opensensmapr changelog
This project does its best to adhere to semantic versioning.

### 2018-09-05: v0.4.2
- move to sensebox GitHub organization
- pass ... to plot.sensebox()

### 2018-06-07: v0.4.1
- fix `osem_as_measurements()` returning wrong classes
- improve vignettes
- be on CRAN eventually.. hopefully??

### 2018-05-25: v0.4.0
- add caching feature for requests; see vignette osem-serialization
- add vignette osem-serialization
- add vignette osem-history
- fix broken parameter check for osem_measurements(phenomenon = )
- increased test coverage
- package ready for CRAN

### 2018-01-13: v0.3.2
- hide download progress in non interactive sessions (#11)
- fix `print.osem_measurements()`
- fix `summary.sensebox()` `last_measurement_within`
- expose `mar` for plot functions (#12)
- remove deprecated NSE functions from dplyr
- package & documentation improvements

### 2017-11-29: v0.3.1
- compatibility with latest API format (#4)
- add package documentation under `?opensensmapr` (#5)

### 2017-09-04: v0.3.0
- add utility functions: `filter`, `mutate`, `[`, `st_as_sf` for classes `sensebox` and `osem_measurements`
- add `osem_as_sensebox` and `osem_as_measurement` constructors

#### breaking changes
- `osem_as_sf` has moved to `st_as_sf.sensebox` and `st_as_sf.osem_measurements`

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
