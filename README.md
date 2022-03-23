
# rjackcess

<!-- badges: start -->
<!-- badges: end -->

rjackcess uses {rJava} to provide a basic interface to the Jackcess <https://jackcess.sourceforge.io/> Java API for MS Access databases. 

More information on the API is available in the Javadocs (<https://javadoc.io/doc/com.healthmarketscience.jackcess/jackcess/latest/index.html>). 


## Installation

You can install the development version of rjackcess like so:

``` r
# install.packages("remotes")
remotes::install_github("brownag/rjackcess")
```

## Example

This is a basic example showing how to create a Database instance from file, call methods associated with that object instance, export data to flat files, and import data back into the MS Access database.

``` r
library(rjackcess)

db <- Database("~/pedon/pedon.accdb")

db$getTableNames()

db$getTable('area')

exportAll(db, "~/pedon/output/")
importFile("~/pedon/output/pedon.csv", db, "pedon", useExistingTable = TRUE)
```

