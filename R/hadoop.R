.hadoop.detect <- function() {
  hh <- Sys.getenv("HADOOP_HOME")
  if (!nzchar(hh)) hh <- Sys.getenv("HADOOP_PREFIX")
  if (!nzchar(hh)) hh <- "/usr/lib/hadoop"
  hcmd <- file.path(hh, "bin", "hadoop")
  if (!file.exists(hcmd)) stop("Cannot find working Hadoop home. Set HADOOP_PREFIX if in doubt.")

  sj <- Sys.getenv("HADOOP_STREAMING_JAR")
  if (!nzchar(sj)) sj <- Sys.glob(file.path(hh, "contrib", "streaming", "*.jar"))
  if (!length(sj)) {
    ver <- system(paste(shQuote(hcmd), "version"), intern=TRUE)[1L]
    if (!isTRUE(grepl("^Hadoop ", ver)))
      stop("Unable to detect hadoop version via", hcmd, ", if needed set HADOOP_PREFIX accordingly")
    ver <- gsub("^Hadoop ", "", ver)
    if (ver >= "2.0") { ## try to use the class path
      cp <- strsplit(system(paste(shQuote(hcmd), "classpath"), intern=TRUE), .Platform$path.sep, TRUE)[[1]]
      sj <- unlist(lapply(cp, function(o) Sys.glob(file.path(gsub("\\*$","",o), "hadoop-streaming-*.jar"))))
    }
  }
  list(hh=hh, hcmd=hcmd, sj=sj)
}
