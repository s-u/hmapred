open.HDFSpath <- function(con, open = "r", ...) {
  hh <- Sys.getenv("HADOOP_HOME")
  if (!nzchar(hh)) hh <- Sys.getenv("HADOOP_PREFIX")
  if (!nzchar(hh)) hh <- "/usr/lib/hadoop"
  hcmd <- file.path(hh, "bin", "hadoop")
  if (!file.exists(hcmd)) stop("Cannot find working Hadoop home. Set HADOOP_PREFIX if in doubt.")

  if (length(grep("+", open, fixed=TRUE))) stop("`open' can only be either read or write but not both")
  if (length(grep("^a", open))) stop("sorry, appending is currently unsupported")
  if (length(grep("^r", open))) {
    fscmd <- if (length(grep("b$", open))) "-cat" else "-text"
    ## try to be friendly and for directories cat the contents
    if (system(paste(hcmd,"fs -test -d",shQuote(con))) == 0)
      pipe(paste(hcmd,"fs",fscmd,shQuote(paste0(con, "/*"))), open=open)
    else
      pipe(paste(hcmd,"fs",fscmd,shQuote(con)), open=open)
  } else if (length(grep("^w", open)))
    pipe(paste(hcmd,"fs -put -", shQuote(con)), open=open)
  else
    stop("invalid mode '", open, "' for HDFS paths")
}

print.HDFSpath <- function(x, ...) {
  cat(paste0("HDFS path: ", as.character(x), "\n"))
  invisible(x)
}
