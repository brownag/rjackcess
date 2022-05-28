tf <- tempfile(fileext = ".accdb")
td <- tempfile(fileext = ".csv")
tt <- file.path(tempdir(), "test.csv")

expect_silent(db <- Database(tf))

write.csv(data.frame(
  a = 1:10,
  b = letters[1:10],
  c = seq(as.Date("2020-01-01"), as.Date("2020-01-10"), by = 1)),
  file = td, row.names = FALSE
)

expect_silent(importFile(td, db, 'test'))
expect_silent(exportAll(db, tempdir()))
expect_true(file.exists(tt))

# db$getTableNames()
# db$getTable('test')

unlink(tf, td, tt)
