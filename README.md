## hmr - Hadoop Map/Reduce package for R

High-performance Hadoop Map/Reduce R interface based on
[iotools](/s-u/iotools). Main feature is the use of chunk-wise
processing and automatic conversion to/from R objects as to make it
very easy for users to run existing R code on Hadoop while providing
much higher performance than "classic" key/value operations as used in
other packages like `rmr`.

For high-level discussion see the [iotools
Wiki](https://github.com/s-u/iotools/wiki)

The main package webpage is on [RForge.net](http://RForge.net/hmr) and you can
install `hmr` from latest sources using

    install.packages("hmr",,"http://rforge.net")
    
in R. The RForge.net repository is updated on every commit.
