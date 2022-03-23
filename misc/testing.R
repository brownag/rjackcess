library(rjackcess)

db <- Database("~/pedon/pedon.accdb")

db$getTableNames()
tb <- db$getTable('area')

exportAll(db, "~/pedon/output/")
importFile("~/pedon/output/pedon.csv", db, "pedon", useExistingTable = TRUE, header = TRUE)
