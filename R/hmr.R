hmr <- function(input, output, map=identity, reduce=identity, job.name, aux, formatter, packages=loadedNamespaces(), reducers,
                wait=TRUE, hadoop.conf, hadoop.opt, R="R", verbose=TRUE, persistent=FALSE, overwrite=FALSE,
                use.kinit = !is.null(getOption("hmr.kerberos.realm"))) {
  .rn <- function(n) paste(sprintf("%04x", as.integer(runif(n, 0, 65536))), collapse='')
  if (missing(output)) output <- hpath(sprintf("/tmp/io-hmr-temp-%d-%s", Sys.getpid(), .rn(4)))
  if (missing(job.name)) job.name <- sprintf("RCloud:iotools:hmr-%s", .rn(2))
  if (!inherits(input, "HDFSpath")) stop("Sorry, you have to have the input in HDFS for now")
  ## only use kinit if use.kinit and all tickets expired
  if (isTRUE(use.kinit) && all(krb5::klist()$expired)) krb5::kinit(realm=getOption("hmr.kerberos.realm"))
  map.formatter <- NULL
  red.formatter <- NULL
  if (missing(formatter) && inherits(input, "hinput")) map.formatter <- attr(input, "formatter")
  if (!missing(formatter)) {
    if (is.list(formatter)) {
      map.formatter <- formatter$map
      red.formatter <- formatter$reduce
    } else map.formatter <- red.formatter <- formatter
  }
  ## this could be true with formatter=list(reduce=...) in which case we still use the one from input
  if (is.null(map.formatter) && inherits(input, "hinput")) map.formatter <- attr(input, "formatter")
  if (is.null(map.formatter)) map.formatter <- .default.formatter
  if (is.null(red.formatter)) red.formatter <- .default.formatter

  h <- .hadoop.detect()
  hh <- h$hh
  hcmd <- h$hcmd
  sj <- h$sj
  if (!length(sj))
     stop("Cannot find streaming JAR - set HADOOP_STREAMING_JAR or make sure you have a complete Hadoop installation")

  e <- new.env(parent=emptyenv())
  if (!missing(aux)) {
    if (is.list(aux)) for (n in names(aux)) e[[n]] <- aux[[n]]
    else if (is.character(aux)) for (n in aux) e[[n]] <- get(n) else stop("invalid aux")
  }
  e$map.formatter <- map.formatter
  e$red.formatter <- red.formatter
  e$map <- map
  e$reduce <- reduce
  e$load.packages <- packages
  f <- tempfile("hmr-stream-dir")
  dir.create(f,, TRUE, "0700")
  owd <- getwd()
  on.exit(setwd(owd))
  setwd(f)
  save(list=ls(envir=e, all.names=TRUE), envir=e, file="stream.RData")
  map.cmd <- if (isTRUE(persistent)) {
     paste0("-mapper \"",R," --slave --vanilla -e 'hmr:::run.ro()'\"")
  } else {
    if (identical(map, identity)) "-mapper cat" else if (is.character(map)) paste("-mapper", shQuote(map[1L])) else paste0("-mapper \"",R," --slave --vanilla -e 'hmr:::run.map()'\"")
  }
  reduce.cmd <- if (identical(reduce, identity)) "" else if (is.character(reduce)) paste("-reducer", shQuote(reduce[1L])) else paste0("-reducer \"",R," --slave --vanilla -e 'hmr:::run.reduce()'\"")
  extraD <- if (missing(reducers)) "" else paste0("-D mapred.reduce.tasks=", as.integer(reducers))
  if (!missing(hadoop.opt) && length(hadoop.opt)) {
    hon <- names(hadoop.opt)
    extraD <- if (is.null(hon))
      paste(extraD, paste(as.character(hadoop.opt), collapse=" "))
    else
      paste(extraD, paste("-D", shQuote(paste0(hon, "=", as.character(hadoop.opt))), collapse=" "))
  }

  hargs <- paste(
               "-D", "mapreduce.reduce.input.limit=-1",
               "-D", shQuote(paste0("mapred.job.name=", job.name)), extraD,
               paste("-input", shQuote(input), collapse=' '),
               "-output", shQuote(output),
               "-file", "stream.RData",
               map.cmd, reduce.cmd)
  cfg <- ""
  if (!missing(hadoop.conf)) cfg <- paste("--config", shQuote(hadoop.conf)[1L])

  ## FIXME: to support Hadoop 1 it woudl have to be rmr?
  if (overwrite) system(paste(shQuote(hcmd), "fs", "-rm", "-r", shQuote(output)), ignore.stdout = TRUE, ignore.stderr = FALSE)
  h0 <- paste(shQuote(hcmd), cfg, "jar", shQuote(sj[1L]))
  cmd <- paste(h0, hargs)
  system(cmd, wait=wait, ignore.stdout = !verbose, ignore.stderr = !verbose)

  output
}
