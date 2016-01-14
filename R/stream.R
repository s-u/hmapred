run.chunked <- function(FUN, formatter=mstrsplit, key.sep=NULL) {
  ## we have to load stream.RData first since it actually contains FUN (thank you lazy evaluation - the only reason why this works at all)
  load("stream.RData", .GlobalEnv)

  ## FIXME: it would be nice to test for 'identity' but since this may have been serialized, identical() may not help here ...
  if (is.null(FUN) || identical(FUN, identity)) { ## pass-through, no chunking, just behave like `cat`
    input <- file("stdin", "rb")
    N <- 16777216L ## 16Mb
    while (length(buf <- readBin(input, raw(), N))) writeBIN(buf, FALSE) 
    writeBIN(raw(), TRUE) ## just a flush
    return(invisible(TRUE))
  }

  if (!is.null(.GlobalEnv$prefix.library.path))
    .libPaths(c(as.character(.GlobalEnv$prefix.library.path), .libPaths()))
  if (!is.null(.GlobalEnv$load.packages))
    try(for(i in .GlobalEnv$load.packages) require(i, quietly=TRUE, character.only=TRUE), silent=TRUE)
  input <- file("stdin", "rb")
  output <- stdout()
  chunk.size <- 33554432L
  max.line <- 131072L
  if (is.numeric(.GlobalEnv$chunk.size)) chunk.size <- .GlobalEnv$chunk.size
  if (is.numeric(.GlobalEnv$max.line)) max.line <- .GlobalEnv$max.line
  if (max.line > chunk.size) chunk.size <- as.integer(max.line * 1.2)
  reader <- chunk.reader(input, sep=key.sep, max.line=max.line)
  while (TRUE) {
    chunk <- read.chunk(reader, chunk.size)
    if (!length(chunk)) break
    res <- FUN(formatter(chunk))
    if (length(res)) {
      if (!is.raw(res)) res <- as.output(res)
      if (is.raw(res)) writeLines(rawToChar(res), output, sep='') else writeLines(res, output)
    }
  }
  invisible(TRUE)
}

run.map <- function() run.chunked(.GlobalEnv$map, .GlobalEnv$map.formatter)
run.reduce <- function() run.chunked(.GlobalEnv$reduce, .GlobalEnv$red.formatter, "\t")

