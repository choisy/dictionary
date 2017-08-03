# Dictionary of the names of the provinces -------------------------------------

provinces <- read.table("data-raw/provinces.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
provinces <- with(provinces, setNames(new, old))

# Writing to disk --------------------------------------------------------------

devtools::use_data(provinces, overwrite = TRUE)
