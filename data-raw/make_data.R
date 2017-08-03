provinces <- read.table("data-raw/provinces.txt", sep = ";",
                        header = TRUE, stringsAsFactors = FALSE)
provinces <- with(provinces, setNames(new, old))
devtools::use_data(provinces, overwrite = TRUE)
