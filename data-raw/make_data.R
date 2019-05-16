# Dictionary of the names of the communes in Vietnam ---------------------------

communes <- read.table("data-raw/vietnam/communes.txt", sep = ";",
                       header = TRUE, stringsAsFactors = FALSE)
communes$old <- stringi::stri_escape_unicode(communes$old)
admin3 <- with(communes, setNames(new, old))

# Writing to disk --------------------------------------------------------------

usethis::use_data(admin3, overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
