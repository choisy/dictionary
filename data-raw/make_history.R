# Packages and System ----------------------------------------------------------
library(magrittr) # for " %>% "
library(dplyr)    # for "select" and "mutate"
library(purrr)    # for "map", "transpose" and "keep"
library(stringr)  # for "str_extract" and "str_detect"

# Prerequisite -----------------------------------------------------------------

# The history of the change of administrative boundaries by country can be
# inputed as text file and will be returned as list.
# The text file should be written in a specific format and one event per line:
#
# "In DATE, ADMIN1(s) (ADMIN2(s)) EVENT in ADMIN1(s).
# aADMIN1(s): if multiple, separated by ";"
# If the details of the split/merge event if available at admin2 level, the
# admin2 should be written in (), separated by "," and the event should be
# written complex EVENT
# DATE: written by year as "YYYY" or can be a full date written as "YYYY-mm_dd"
# EVENT: choose betwrepreen: split(s)/merge/rename(s)
#
# For example: In 1992, Hau Giang splits in Can Tho; Soc Trang.
# For example: In 2013, Vientiane (Longsan, Xaysomboun, Phun, Hom);
#                       Xiengkhuang (Thathon) complex splits in Xaisomboun.

# Functions --------------------------------------------------------------------

# Function to recognize if a vector contains digit, returns TRUE for each object
# of the vector containing no numerics.
is_notnumeric <- function(vect) {
  grepl("[[:digit:]]", vect, ignore.case = TRUE) == FALSE
}


# Splits the vector by `EVENT`
split_event <- function(vect){
  vect %<>% gsub("splits", "split", .) %>%
    gsub("renames", "rename", .) %>%
    gsub("merges", "merge", .) %>%
    strsplit(split = "split|merge|rename|complex split|complex merge")
}

# Function to translate the Vietnase admin1 names in UNICODE and English.
translate <- function(vect, hash) {
  vect %<>%
    gsub(" in ", "", .) %>%
    gsub("\\.", "", .) %>%
    gsub(" $", "", .) %>%
    gsub("^ ", "", .) %>%
    stringi::stri_escape_unicode() %>%
    hash[.] %>%
    as.character()
}

# Function to identify the event and return a vector of character
id_event <- function(vect) {
  ifelse(agrepl("complex split", vect), "complex split",
         ifelse(agrepl("complex merge", vect), "complex merge",
                ifelse(agrepl("split", vect), "split",
                       ifelse(agrepl("merge", vect), "merge", "rename"))))
}

# Function to identify the date and return a vector of character
id_date <- function(vect) {
  gsub("[^[:digit:]]", "", vect) %>%
    paste0(., "-01-01") %>%
    as.Date() %>%
    as.character()
}

# Function to identify the admin1 name and return a vector of character,
# the extractor parametes permit to select the admin1 names before (1) or
# after (2) the event. Hash for the translation of the admin1 name in a
# standardized format
id_admin1 <- function(vect, extractor, hash) {
  vect %>%
    split_event(.) %>% map(extractor) %>% unlist() %>%
    strsplit(";") %>% map(str_extract, ".*(?=(\\(.+\\)))|.*") %>%
    map(strsplit, ", ") %>% map(unlist) %>% map(keep, is_notnumeric) %>%
    map(translate, hash) %>% map(as.list)
}

# Function to identify the admin2s name and return a vector of character,
# the extractor parametes permit to select the admin2 names before (1) or
# after (2) the event. Hash for the translation of the admin2 name in a
# standardized format
id_admin2 <- function(vect, extractor, hash_p, hash_d) {
  lst <- lapply(split_event(vect), "[", extractor)
  lst <- strsplit(unlist(lst), ";|[[:digit:]],")
  lst <- unlist(lst)
  lst <- lst[which(lst != "" & !grepl("In ", lst))]
  lst <- data.frame(admin1 = lst)

  admin2 <- str_extract(lst$admin1, "\\(.+\\)")
  admin2 <- gsub("\\(|\\)", "", admin2)
  admin2 <- strsplit(admin2, ", ")
  admin2 <- lapply(admin2, function(x) translate(x, hash_d))

  admin1 <- str_extract(lst$admin1, ".*(?=(\\(.+\\)))|.*")
  admin1 <- gsub(" in ", "", admin1)
  admin1 <- lapply(admin1, function(x) translate(x, hash_p))
  admin1 <- rep(admin1, lapply(admin2, length))

  df <- data.frame(admin1 = unlist(admin1), admin2 = unlist(admin2))
  list(df)
}

# From a text file (see prerequisite), make a list of list of 4 elements:
# 'year': date of event in character,
# 'event': character either split, merge or rename,
# 'before': name of the admin1(s) before the event in a list and
# 'after': name of the admin1(s) after the event in a list
# 'd.before' : name of the admin2s concerned by the event (only for complex event)
# 'd.after' : name of the admin2s concerned by the event (only for complex event)
make_history <-  function(file, hash, d.hash) {

  hist_list <- read.delim(file, header = FALSE)

  df <- mutate(hist_list,
               year = id_date(V1),
               event = id_event(V1),
               before = id_admin1(V1, 1, hash),
               after = id_admin1(V1, 2, hash))

  if (any(df$event %>% str_detect("complex"))) {
    df %<>% mutate(
      d.before = id_admin2(V1, 1, hash, d.hash),
      d.after = id_admin2(V1, 2, hash, d.hash))
  }

  df %>%
    select(-V1) %>%
    transpose(.)
}

# Data -------------------------------------------------------------------------

vn_history <- make_history("data-raw/History_txtfile/vn_history.txt",
                           dictionary::vn_admin1)

th_history <- make_history("data-raw/History_txtfile/th_history.txt",
                           dictionary::th_admin1)

la_history <- make_history("data-raw/History_txtfile/la_history.txt",
                           dictionary::la_admin1,
                           dictionary::la_admin2)

kh_history <- make_history("data-raw/History_txtfile/kh_history.txt",
                           dictionary::kh_admin1)

# Writing to disk --------------------------------------------------------------

usethis::use_data(vn_history, th_history, la_history, kh_history,
                   overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
