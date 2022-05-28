test_that("jackcess works", {
  library(rjackcess)
  tf <- tempfile(fileext = ".accdb")
  db <- Database(tf)
})
