# opensensmapr

[![CRAN status](https://www.r-pkg.org/badges/version/opensensmapr)](https://cran.r-project.org/package=opensensmapr)
[![Travis build status](https://travis-ci.org/sensebox/opensensmapR.svg?branch=master)](https://travis-ci.org/sensebox/opensensmapR)
[![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/dtad4ves48gebss7/branch/master?svg=true)](https://ci.appveyor.com/project/noerw/opensensmapr/branch/master)
[![Coverage status](https://codecov.io/gh/sensebox/opensensmapR/branch/master/graph/badge.svg)](https://codecov.io/github/sensebox/opensensmapR?branch=master)

This R package ingests data from the API of [opensensemap.org][osem] for analysis in R.

Features include:

- `osem_boxes()`: fetch sensor station ("box") metadata, with various filters
- `osem_measurements()`: fetch measurements by phenomenon, with various filters such as submitting spatial extent, time range, sensor type, box, exposure..
  - no time frame limitation through request paging!
- many helper functions to help understand the queried data
- caching queries for reproducibility

The package aims to be compatible with the [`tidyverse`][tidy] and [`sf`][sf],
so it is easy to analyze or vizualize the data with state of the art packages.

[osem]: https://opensensemap.org/
[sf]: https://github.com/r-spatial/sf
[tidy]: https://www.tidyverse.org/

## Usage

Complete documentation is provided via the R help system:
Each function's documentation can be viewed with `?<function-name>`.
A comprehensive overview of all functions is given in `?opensensmapr`.

There are also vignettes showcasing applications of this package:

- [Visualising the History of openSenseMap.org][osem-history]: Showcase of `opensensmapr` with `dplyr` + `ggplot2`
- [Exploring the openSenseMap dataset][osem-intro]: Showcase of included helper functions
- [Caching openSenseMap Data for reproducibility][osem-serialization]

[osem-intro]: https://sensebox.github.com/opensensmapR/inst/doc/osem-intro.html
[osem-history]: https://sensebox.github.com/opensensmapR/inst/doc/osem-history.html
[osem-serialization]: https://sensebox.github.com/opensensmapR/inst/doc/osem-serialization.html

If you used this package for an analysis and think it could serve as a good
example or showcase, feel free to add a vignette to the package via a [PR](#contribute)!

## Installation

The package is available on CRAN, install it via

```r
install.packages('opensensmapr')
```

To install the very latest versions from GitHub, run:

```r
install.packages('devtools')
devtools::install_github('sensebox/opensensmapr@master')      # latest stable version
devtools::install_github('sensebox/opensensmapr@development') # bleeding edge version
```

## Changelog

This project adheres to semantic versioning, for changes in recent versions please consult [CHANGES.md](CHANGES.md).

## Contributing & Development

Contributions are very welcome!
When submitting a patch, please follow the existing [code style](.lintr),
and run `R CMD check --no-vignettes .` on the package.
Where feasible, also add tests for the added / changed functionality in `tests/testthat`.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.

### development environment

To set up the development environment for testing and checking, all suggested packages should be installed.
On linux, these require some system dependencies:
```sh
# install dependencies for sf (see https://github.com/r-spatial/sf#installing)
sudo dnf install gdal-devel proj-devel proj-epsg proj-nad geos-devel udunits2-devel

# install suggested packages
R -e "install.packages(c('maps', 'maptools', 'tibble', 'rgeos', 'sf',
    'knitr', 'rmarkdown', 'lubridate', 'units', 'jsonlite', 'ggplot2',
    'zoo', 'lintr', 'testthat', 'covr')"
```

### build

To build the package, either use `devtools::build()` or run
```sh
R CMD build .
```

Next, run the **tests and checks**:
```sh
R CMD check --as-cran ../opensensmapr_*.tar.gz
# alternatively, if you're in a hurry:
R CMD check --no-vignettes ../opensensmapr_*.tar.gz
```

### release

To create a release:

0. make shure you are on master branch
1. run the tests and checks as described above
2. bump the version in `DESCRIPTION`
3. update `CHANGES.md`
3. rebuild the documentation: `R -e 'devtools::document()'`
4. build the package again with the new version: `R CMD build . --no-build-vignettes`
5. tag the commit with the new version: `git tag v0.5.0`
6. push changes: `git push && git push --tags`
7. wait for *all* CI tests to complete successfully (helps in the next step)
8. [upload the new release to CRAN](https://cran.r-project.org/submit.html)
9. get back to the enjoyable parts of your life & hope you won't get bad mail next week.


## License

GPL-2.0 - Norwin Roosen
