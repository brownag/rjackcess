# rjackcess 0.2.0

* Added constructor for `SimpleExportFilter()`
* Added `getTableNames()` and `getColumnMetadata()` methods allowing for additional information about contents of database to be easily determined
* Update to `exportAll()`: added new arguments to support custom output file extensions, delimiters, include headers, and custom export filters. Default behavior will now produce CSV files _WITH_ headers!
  * **Breaking change**: `dsn` argument to `exportAll()` has been renamed to `outdir`
  * `db` argument can now accept a file path to MS Access Database which will construct a Database object with `Database()`. Additional options for constructing database instance can be passed via `...`.
* Update to `importFile()`: quote argument is now converted to Java character primitive internally.

# rjackcess 0.1.0

* Added constructors for key Jackcess classes (`Database()` and `SimpleImportFilter()`)
* Added `exportAll()` and `importFile()` methods allowing for dumping of all tables in a data base to flat file, and importing flat files into new/existing tables
* Added a `NEWS.md` file to track changes to the package.
