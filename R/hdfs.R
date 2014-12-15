hpath <- function(path) structure(path, class="HDFSpath")

.default.formatter <- function(x) {
  y <- mstrsplit(x, "|", "\t")
  if (ncol(y) == 1L) y[, 1] else y
}

hinput <- function(path, formatter=.default.formatter)
  structure(path, class=c("hinput", "HDFSpath"), formatter=formatter)

c.hinput = function(..., recursive = FALSE) {
  if(!all(sapply(list(...), function(v) all.equal(attr(v, "class"), c("hinput", "HDFSpath"))) == TRUE)) {
    warning("Using default combine function as not all objects are of class hinput")
    return(c(sapply(list(...), function(v) as.character(v))))
  }
  formatters = sapply(list(...), function(v) attr(v, "formatter"))
  if(!all(sapply(formatters, all.equal, formatters[[1]]))) {
    stop("All input objects must have the same formatters")
  }

  return(structure(unique(c(sapply(list(...), function(v) as.character(v)))),
         class=c("hinput", "HDFSpath"), formatter=formatters[[1]]))
}
