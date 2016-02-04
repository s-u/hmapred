## hmr - Hadoop Map/Reduce package for R

High-performance Hadoop Map/Reduce R interface based on
[iotools](/s-u/iotools). Main feature is the use of chunk-wise
processing and automatic convertion to/from R objects as to make it
very easy for users to run existing R code on Hadoop while providing
much higher performance that "classic" key/value operations as used in
other packages like `rmr`.

For high-level discussion see the [iotools
Wiki](https://github.com/s-u/iotools/wiki)

The main package webpage is (http://RForge.net/hmr) and you can
install it from latest sources using

    install.packages("hmr",,"http://rforge.net")
    
in R, the RForge.net repository is updated on every commit.
