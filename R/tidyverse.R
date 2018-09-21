# helpers for the dplyr & co related functions
# also custom method registration

# they need to be registered, but not exported, see https://github.com/klutometis/roxygen/issues/796
# we're using a different workaround than suggested, copied from edzer's sf package:
# dynamically register the methods only when the related package is loaded as well.

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

register_s3_method('dplyr', 'filter', 'sensebox')
register_s3_method('dplyr', 'mutate', 'sensebox')
register_s3_method('dplyr', 'filter', 'osem_measurements')
register_s3_method('dplyr', 'mutate', 'osem_measurements')
register_s3_method('sf', 'st_as_sf', 'sensebox')
register_s3_method('sf', 'st_as_sf', 'osem_measurements')
