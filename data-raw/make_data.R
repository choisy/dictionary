# Dictionary of the names of the provinces -------------------------------------

provinces <- read.table("data-raw/provinces.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
provinces <- with(provinces, setNames(new, old))

# Dictionary of the names of the provinces -------------------------------------

districts <- read.table("data-raw/districts.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
districts <- with(districts, setNames(new, old))

# Dictionary of the names of the provinces -------------------------------------

communes <- read.table("data-raw/communes.txt", sep = ";",
                       header = TRUE, stringsAsFactors = FALSE)
communes <- with(communes, setNames(new, old))

# Writing to disk --------------------------------------------------------------

devtools::use_data(provinces, districts, communes, overwrite = TRUE)
