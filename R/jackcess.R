#' Initialize a Jackcess `Database` object instance for interacting with MS Access database files
#'
#' @param dsn data source file path
#' @param read_only open connection as read-only? Default `FALSE`
#' @param file_format one of the following: `"GENERIC_JET4"`, `"MSISAM"`, `"V1997"`, `"V2000"`, `"V2003"`, `"V2007"`, `"V2010"`, `"V2016"`, `"V2019"`. See details.
#' @param overwrite overwrite existing file? Default `FALSE`
#' @details
#' - `"GENERIC_JET4"` - A database which was most likely created programmatically
#' - `"MSISAM"` - A database which was created by MS Money
#' - `"V1997"` - A database which was created by MS Access 97
#' - `"V2000"` - A database which was created by MS Access 2000
#' - `"V2003"` - A database which was created by MS Access 2002/2003
#' - `"V2007"` - A database which was created by MS Access 2007
#' - `"V2010"` - A database which was created by MS Access 2010+
#' - `"V2016"` - A database which was created by MS Access 2016+
#' - `"V2019"` - A database which was created by MS Access 2019+ (Office 365)
#' @return a com.healthmarketscience.jackcess.Database object
#' @export
#' @importFrom rJava .jnew .jfield
Database <- function(dsn, read_only = FALSE, file_format = c("V2019", "V2016", "V2010",
                                                             "V2007", "V2003", "V2000",
                                                             "V1997", "MSISAM", "GENERIC_JET4"), overwrite = FALSE) {
  file_format <- match.arg(file_format)
  f <- rJava::.jnew("java/io/File", path.expand(dsn))
  dbb <- rJava::.jnew("com/healthmarketscience/jackcess/DatabaseBuilder")
  if (read_only) {
    dbb$setReadOnly(TRUE)
  }
  if (!file.exists(dsn) || overwrite) {
    dbb$setFile(f)
    dbb$setFileFormat(rJava::.jfield("com.healthmarketscience.jackcess.Database$FileFormat", NULL, file_format))
    return(dbb$create())
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
