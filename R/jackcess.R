#' Initialize a Database object instance for interacting with MS Access database files
#'
#' @param dsn data source file path
#' @param read_only open connection as read-only? Default `FALSE`
#' @return a com.healthmarketscience.jackcess.Database object
#' @export
#' @importFrom rJava .jnew
Database <- function(dsn, read_only = FALSE) {
  f <- rJava::.jnew("java/io/File", path.expand(dsn))
  dbb <- rJava::.jnew("com/healthmarketscience/jackcess/DatabaseBuilder")
  if (read_only) {
    dbb$setReadOnly(TRUE)
  }
  dbb$open(f)
}

#' ExportUtilBuilder
#'
#' @return a com.healthmarketscience.jackcess.util.ExportUtil object
#' @noRd
#' @keywords internal
ExportUtilBuilder <- function() {
  rJava::.jnew("com/healthmarketscience/jackcess/util/ExportUtil")
}

#' Export contents of a MS Access Database to Flat Files
#' @param db a Database object
#' @param dsn directory path for output files
#' @export
exportAll <- function(db, dsn) {

  if (!dir.exists(dsn)) {
    dir.create(dsn, recursive = TRUE, showWarnings = FALSE)
  }

  ExportUtilBuilder()$exportAll(db, rJava::.jnew("java/io/File", path.expand(dsn)))
}


#' ImportUtilBuilder
#'
#' @return a com.healthmarketscience.jackcess.util.ImportUtil object
#' @noRd
#' @keywords internal
ImportUtilBuilder <- function() {
  rJava::.jnew("com/healthmarketscience/jackcess/util/ImportUtil")
}

#' SimpleImportFilter
#' @return a com.healthmarketscience.jackcess.util.SimpleImportFilter object
#' @export
SimpleImportFilter <- function() {
  rJava::.jnew("com/healthmarketscience/jackcess/util/SimpleImportFilter")
}

#' Import a delimited flat file into a new or existing MS Access Database table
#'
#' @param dsn Input file path
#' @param db a Database object
#' @param name Table name
#' @param delim Delimiter (default (`,`))
#' @param quote Quote character (default `"`)
#' @param filter Optional custom ImportFilter object
#' @param useExistingTable logical. Use existing tables? Default: `FALSE`
#' @param header logical. Input file contains headers? Default: `TRUE`
#'
#' @export
importFile <-  function(dsn,
                        db,
                        name,
                        delim = ",",
                        quote = rJava::.jchar('"'),
                        filter = SimpleImportFilter()$INSTANCE,
                        useExistingTable = FALSE,
                        header = TRUE) {

  if (!file.exists(dsn)) {
    stop(sprintf("File (%s) does not exist", dsn), call. = FALSE)
  }
  f <- rJava::.jnew("java/io/File", path.expand(dsn))
  # TODO: custom import filter for casting java.lang.Boolean -> java.lang.Number for area.obterm
  ImportUtilBuilder()$importFile(f, db, name, delim, quote, filter, useExistingTable, header)
}
