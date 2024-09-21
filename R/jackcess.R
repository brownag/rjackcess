#' Initialize a Jackcess `Database` object instance for interacting with MS Access database files
#'
#' @param dsn _character_. MS Access database source name (file path).
#' @param read_only _logical_ Open connection as read-only? Default `FALSE`
#' @param file_format _character_. One of the following: `"GENERIC_JET4"`, `"MSISAM"`, `"V1997"`, `"V2000"`, `"V2003"`, `"V2007"`, `"V2010"`, `"V2016"`, `"V2019"`. See details.
#' @param overwrite _logical_. overwrite existing file? Default `FALSE`
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
#' @return A _com.healthmarketscience.jackcess.Database_ object
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
#'
#' @param db A  _com.healthmarketscience.jackcess.Database_ object or character path to MS Access Database.
#' @param outdir Directory path for output files.
#' @param extension Output file extension. Default: `"csv"`.
#' @param header Include column names in header? Default: `TRUE`.
#' @param delim Output file delimiter. Default: `","`
#' @param quote Output file quote character. Default: `'"'`
#' @param filter Export filter. Default: `SimpleExportFilter()$INSTANCE`
#' @param ... Additional arguments passed to `Database()` when `db` is a file path.
#' @export
exportAll <- function(
    db,
    outdir,
    extension = "csv",
    header = TRUE,
    delim = ",",
    quote = '"',
    filter = SimpleExportFilter()$INSTANCE,
    ...
) {
  
  if (is.character(db)) {
    db <- Database(db, ...)
  } else {
    if (!inherits(db, "jobjRef")) {
      stop("`db` argument should be a character file path to MS Access Database, or an object created with `Database()` method", call. = TRUE)
    }
  }
  
  if (!dir.exists(outdir)) {
    dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
  }

  ExportUtilBuilder()$exportAll(db, 
                                rJava::.jnew("java/io/File", path.expand(outdir)),
                                extension,
                                header,
                                delim,
                                rJava::.jchar(quote),
                                filter)
}


#' ImportUtilBuilder
#'
#' @return A _com.healthmarketscience.jackcess.util.ImportUti_ object
#' @noRd
#' @keywords internal
ImportUtilBuilder <- function() {
  rJava::.jnew("com/healthmarketscience/jackcess/util/ImportUtil")
}

#' SimpleImportFilter
#' @return A _com.healthmarketscience.jackcess.util.SimpleImportFilter_ object
#' @export
SimpleImportFilter <- function() {
  rJava::.jnew("com/healthmarketscience/jackcess/util/SimpleImportFilter")
}


#' SimpleExportFilter
#' @return A _com.healthmarketscience.jackcess.util.SimpleImportFilter_ object
#' @export
SimpleExportFilter <- function() {
  rJava::.jnew("com/healthmarketscience/jackcess/util/SimpleExportFilter")
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
                        quote = '"',
                        filter = SimpleImportFilter()$INSTANCE,
                        useExistingTable = FALSE,
                        header = TRUE) {

  if (!file.exists(dsn)) {
    stop(sprintf("File (%s) does not exist", dsn), call. = FALSE)
  }
  f <- rJava::.jnew("java/io/File", path.expand(dsn))
  # TODO: custom import filter for casting java.lang.Boolean -> java.lang.Number for area.obterm
  ImportUtilBuilder()$importFile(f, db, name, delim, rJava::.jchar(quote), filter, useExistingTable, header)
}

#' Get Names of Tables in Database
#'
#' Get a character vector of all table names in specified database.
#' 
#' @param db A _com.healthmarketscience.jackcess.Database_ object (e.g. created by `Database()`)
#'
#' @return character
#' @export
#'
#' @seealso Database
getTableNames <- function(db) {
  sapply(as.list(db$getTableNames()), function(x) x$toString())
}

#' Get Column Metadata
#' 
#' Get information about columns in specified table(s).
#'
#' @param db A _com.healthmarketscience.jackcess.Database_ object (e.g. created by `Database()`)
#' @param table_names character. Database table name. Default `NULL` will return metadata for all tables in `db`.
#'
#' @return _data.frame_ containing database name (`database_name`; character), table name (`table_name`; character), column name (`column_name`; character), column data type (`datatype`; character), column length (`length`; integer), column length in units (`lengthinunits`; integer), column precision (`precision`; integer), column scale (`scale`; integer), column SQL type (`sqltype`; integer), column "is append only? (`appendonly`; logical), column "is autonumber?" (`autonumber`; logical), column "is calculated?" (`calculated`; logical), column "is compressed unicode?" (`compressedunicode`; logical), column "is hyperlink?" (`hyperlink`; logical), column "is variable length?" (`variablelength`; logical)
#' @export
#'
#' @seealso Database getTableNames
getColumnMetadata <- function(db, table_names = NULL) {
  if (is.null(table_names)) {
    table_names <- getTableNames(db)
  }
  do.call('rbind', lapply(table_names, function(tn) {
    do.call('rbind', lapply(as.list(db$getTable(tn)$getColumns()), function(x)
      data.frame(
        database_name = x$getDatabase()$getName(),
        table_name = x$getTable()$getName(),
        column_name = x$getName(),
        datatype = x$getType()$toString(),
        length = x$getLength(),
        lengthinunits =	x$getLengthInUnits(),
        precision = x$getPrecision(),
        scale = x$getScale(),
        sqltype = x$getSQLType(),
        # versionhistory = x$getVersionHistoryColumn(),
        appendonly = x$isAppendOnly(),
        autonumber = x$isAutoNumber(),
        calculated = x$isCalculated(),
        compressedunicode = x$isCompressedUnicode(),
        hyperlink = x$isHyperlink(),
        variablelength = x$isVariableLength()
      )))
  }))
}