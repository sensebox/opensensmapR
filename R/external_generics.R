# helpers for the dplyr & co related functions
# also delayed method registration
#
# Methods for external generics (except when from `base`) should be registered,
# but not exported: see https://github.com/klutometis/roxygen/issues/796
# Until roxygen supports this usecase properly, we're using a different
# workaround than suggested, copied from edzer's sf package:
# dynamically register the methods only when the related package is loaded as well.


# ====================== base generics =========================

#' maintains class / attributes after subsetting
#' @noRd
#' @export
`[.sensebox` = function(x, i, ...) {
  s = NextMethod('[')
  mostattributes(s) = attributes(s)
  s
}

#' maintains class / attributes after subsetting
#' @noRd
#' @export
`[.osem_measurements` = function(x, i, ...) {
  s = NextMethod()
  mostattributes(s) = attributes(x)
  s
}


# ====================== dplyr generics =========================

#' Simple factory function meant to implement dplyr functions for other classes,
#' which call an callback to attach the original class again after the fact.
#'
#' @param callback The function to call after the dplyr function
#' @noRd
dplyr_class_wrapper = function(callback) {
  function(.data, ..., .dots) callback(NextMethod())
}

#' Return rows with matching conditions, while maintaining class & attributes
#' @param .data A sensebox data.frame to filter
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{filter}}
filter.sensebox = dplyr_class_wrapper(osem_as_sensebox)

#' Add new variables to the data, while maintaining class & attributes
#' @param .data A sensebox data.frame to mutate
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{mutate}}
mutate.sensebox = dplyr_class_wrapper(osem_as_sensebox)

#' Return rows with matching conditions, while maintaining class & attributes
#' @param .data A osem_measurements data.frame to filter
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{filter}}
filter.osem_measurements = dplyr_class_wrapper(osem_as_measurements)

#' Add new variables to the data, while maintaining class & attributes
#' @param .data A osem_measurements data.frame to mutate
#' @param .dots see corresponding function in package \code{\link{dplyr}}
#' @param ... other arguments
#' @seealso \code{\link[dplyr]{mutate}}
mutate.osem_measurements = dplyr_class_wrapper(osem_as_measurements)


# ====================== sf generics =========================

#' Convert a \code{sensebox} dataframe to an \code{\link[sf]{st_sf}} object.
#'
#' @param x The object to convert
#' @param ... maybe more objects to convert
#' @return The object with an st_geometry column attached.
st_as_sf.sensebox = function (x, ...) {
  NextMethod(x, ..., coords = c('lon', 'lat'), crs = 4326)
}

#' Convert a \code{osem_measurements} dataframe to an \code{\link[sf]{st_sf}} object.
#'
#' @param x The object to convert
#' @param ... maybe more objects to convert
#' @return The object with an st_geometry column attached.
st_as_sf.osem_measurements = function (x, ...) {
  NextMethod(x, ..., coords = c('lon', 'lat'), crs = 4326)
}


# from: https://github.com/tidyverse/hms/blob/master/R/zzz.R
# Thu Apr 19 10:53:24 CEST 2018
register_s3_method <- function(pkg, generic, class, fun = NULL) {
  stopifnot(is.character(pkg), length(pkg) == 1)
  stopifnot(is.character(generic), length(generic) == 1)
  stopifnot(is.character(class), length(class) == 1)
  
  if (is.null(fun)) {
    fun <- get(paste0(generic, ".", class), envir = parent.frame())
  } else {
    stopifnot(is.function(fun))
  }
  
  if (pkg %in% loadedNamespaces()) {
    registerS3method(generic, class, fun, envir = asNamespace(pkg))
  }
  
  # Always register hook in case package is later unloaded & reloaded
  setHook(
    packageEvent(pkg, "onLoad"),
    function(...) {
      registerS3method(generic, class, fun, envir = asNamespace(pkg))
    }
  )
}

.onLoad = function(libname, pkgname) {
  register_s3_method('dplyr', 'filter', 'sensebox')
  register_s3_method('dplyr', 'mutate', 'sensebox')
  register_s3_method('dplyr', 'filter', 'osem_measurements')
  register_s3_method('dplyr', 'mutate', 'osem_measurements')
  register_s3_method('sf', 'st_as_sf', 'sensebox')
  register_s3_method('sf', 'st_as_sf', 'osem_measurements')
}
