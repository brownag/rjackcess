
#' @importFrom rJava .jinit .jpackage
.onLoad <- function(libname, pkgname) {

  # rJava setup
  rJava::.jinit()

  rJava::.jpackage("rjackcess")

}

#' @importFrom utils packageVersion
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste0("rjackcess (", packageVersion("rjackcess"), ")"))
}

