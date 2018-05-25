# opensensmapr

[![CRAN status](https://www.r-pkg.org/badges/version/opensensmapr)](https://cran.r-project.org/package=opensensmapr) [![Travis build status](https://travis-ci.org/noerw/opensensmapR.svg?branch=master)](https://travis-ci.org/noerw/opensensmapR) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/noerw/opensensmapR?branch=master&svg=true)](https://ci.appveyor.com/project/noerw/opensensmapR) [![Coverage status](https://codecov.io/gh/noerw/opensensmapR/branch/master/graph/badge.svg)](https://codecov.io/github/noerw/opensensmapR?branch=master)

This R package ingests data (environmental measurements, sensor stations) from the API of opensensemap.org for analysis in R.
The package aims to be compatible with sf and the tidyverse.

## Installation

The package is available on CRAN, install it via

```r
install.packages('opensensmapr')
```

To install the veryy latest from GitHub, run:

```r
install.packages('devtools')
devtools::install_github('noerw/opensensmapr@master')      # latest stable version
devtools::install_github('noerw/opensensmapr@development') # bleeding edge version
```

## Usage

Each function's documentation can be viewed with `?<function-name>`.
An overview is given in `?opensensmapr`.
A verbose usage example is shown in the vignette [`osem-intro`](https://noerw.github.com/opensensmapR/inst/doc/osem-intro.html).

In short, the following pseudocode shows the main functions for data retrieval:

```r
# retrieve a single box by id, or many boxes by some property-filters
b = osem_box('boxId')
b = osem_boxes(filter1, filter2, ...)

# get the counts of observed phenomena for a list of boxes
p = osem_phenomena(b)

# get measurements for a phenomenon
m = osem_measurements(phenomenon, filter1, ...)
# get measurements for a phenomenon from selected boxes
m = osem_measurements(b, phenomenon, filter1, ...)
# get measurements for a phenomenon from a geographic bounding box
m = osem_measurements(bbox, phenomenon, filter1, ...)

# get general count statistics of the openSenseMap database
osem_counts()
```

Additionally there are some helpers: `summary.sensebox(), plot.sensebox(), st_as_sf.sensebox(), osem_as_sensebox(), [.sensebox(), filter.sensebox(), mutate.sensebox(), ...`.

## Changelog

This project adheres to semantic versioning, for changes in recent versions please consult [CHANGES.md](CHANGES.md).

## Contributing & Development

Contributions are very welcome!
When submitting a patch, please follow the existing [code style](.lintr),
and run `R CMD check --no-vignettes .` on the package.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.

## License

GPL-2.0 - Norwin Roosen
