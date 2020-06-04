.hadoop.detect <- function() {
    ver <- NULL

    ## We need to detect HADOOP_HOME and streaming jar
    hh <- Sys.getenv("HADOOP_HOME")
    if (!nzchar(hh)) hh <- Sys.getenv("HADOOP_PREFIX")
    if (!nzchar(hh)) hh <- "/usr/lib/hadoop"
    hcmd <- file.path(hh, "bin", "hadoop")

    ## if HADOOP_HOME is unset and standard loations don't work
    ## try calling `hadoop` to detect it

    if (!file.exists(hcmd)) {
        ## try calling `hadoop`
        ver <- system(paste(shQuote(hcmd), "version"), intern=TRUE)

        ## this really works only for hadoop 2+
        ## in hadoop 1 the jar file was in the root of the installation
        ## also note that we may want to check what HDP or Cloudera report
        ## since they tend to move things around
        if (length(hp <- ver[grep("was run using .*share/hadoop/common/hadoop-common-([^/]+)\\.jar", ver)])) {
            hp <- gsub(".*was run using (.*)share/hadoop/common/hadoop-common-([^/]+)\\.jar", "\\1", hp)
            hcmd <- file.path(hp, "bin", "hadoop")
        }
        if (file.exists(hcmd)) {
            message("HADOOP_HOME not set, but detected from hadoop on the PATH as ", hp, "\nConsider setting HADOOP_HOME or using /usr/lib/hadoop symlink for faster start-up.")
            hh <- hp
        } else
            stop("Cannot find working Hadoop home. Set HADOOP_HOME if in doubt and make sure $HADOOP_HOME/bin/hadoop is present.")
    }

    sj <- Sys.getenv("HADOOP_STREAMING_JAR")
    ## Hadoop 1
    if (!nzchar(sj))
        sj <- Sys.glob(file.path(hh, "contrib", "streaming", "*.jar"))
    ## Hadoop 2+
    if (!length(sj))
        sj <- Sys.glob(file.path(hh, "share", "hadoop", "tools", "lib", "hadoop-streaming-*.jar"))

    ## if none work
    if (!length(sj)) {
        if (is.null(ver))
            ver <- system(paste(shQuote(hcmd), "version"), intern=TRUE)
        if (!isTRUE(grepl("^Hadoop ", ver[1])))
            stop("Unable to detect hadoop version via", hcmd, ", if needed set HADOOP_HOME accordingly")
        ver <- gsub("^Hadoop ", "", ver[1])
        if (ver >= "2.0") { ## try to use the class path
            cp <- strsplit(system(paste(shQuote(hcmd), "classpath"), intern=TRUE), .Platform$path.sep, TRUE)[[1]]
            sj <- unlist(lapply(cp, function(o) Sys.glob(file.path(gsub("\\*$","",o), "hadoop-streaming-*.jar"))))
        }
    }
    list(hh=hh, hcmd=hcmd, sj=sj)
}
