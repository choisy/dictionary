# Dictionary of the names of the provinces -------------------------------------

provinces <- read.table("data-raw/provinces.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
provinces$old <- stringi::stri_escape_unicode(provinces$old)
provinces <- with(provinces, setNames(new, old))

# Dictionary of the names of the provinces -------------------------------------

districts <- read.table("data-raw/districts.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
districts$old <- stringi::stri_escape_unicode(districts$old)
districts <- with(districts, setNames(new, old))

# Dictionary of the names of the provinces -------------------------------------

communes <- read.table("data-raw/communes.txt", sep = ";",
                       header = TRUE, stringsAsFactors = FALSE)
communes$old <- stringi::stri_escape_unicode(communes$old)
communes <- with(communes, setNames(new, old))

# Writing to disk --------------------------------------------------------------

devtools::use_data(provinces, districts, communes, overwrite = TRUE)
