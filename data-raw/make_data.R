# Dictionary of the names of the districts in Vietnam --------------------------

districts <- read.table("data-raw/vietnam/districts.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
districts$old <- stringi::stri_escape_unicode(districts$old)
districts <- with(districts, setNames(new, old))

# Dictionary of the names of the communes in Vietnam ---------------------------

communes <- read.table("data-raw/vietnam/communes.txt", sep = ";",
                       header = TRUE, stringsAsFactors = FALSE)
communes$old <- stringi::stri_escape_unicode(communes$old)
communes <- with(communes, setNames(new, old))

# Writing to disk --------------------------------------------------------------

devtools::use_data(districts, communes, overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
