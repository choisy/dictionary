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
# "In DATE, PROVINCE(s) (DISTRICT(s)) EVENT in PROVINCE(s).
# PROVINCE(s): if multiple, separated by ";"
# If the details of the split/merge event if available at district level, the
# district should be written in (), separated by "," and the event should be
# written complexe EVENT
# DATE: written by year as "YYYY" or can be a full date written as "YYYY-mm_dd"
# EVENT: choose betwrepreen: split(s)/merge/rename(s)
#
# For example: In 1992, Hau Giang splits in Can Tho; Soc Trang.
# For example: In 2013, Vientiane (Longsan, Xaysomboun, Phun, Hom); Xiengkhuang (Thathon) complexe splits in Xaisomboun.

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
    strsplit(split = "split|merge|rename|complexe split|complexe merge")
}

# Function to translate the Vietnase province names in UNICODE and English.
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
  ifelse(agrepl("complexe split", vect), "complexe split",
         ifelse(agrepl("complexe merge", vect), "complexe merge",
                ifelse(agrepl("split", vect), "split",
                       ifelse(agrepl("merge", vect), "merge", "rename"))))
}

# Function to identify the date and return a vector of character
id_date <- function(vect) {
  gsub("[^[:digit:]]", "", vect) %>%
    paste0(., "-01-01") %>%
    as.Date %>%
    as.character
}

# Function to identify the province name and return a vector of character,
# the extractor parametes permit to select the province names before (1) or
# after (2) the event. Hash for the translation of the province name in a
# standardized format
id_province <- function(vect, extractor, hash) {
  vect %>%
    split_event(.) %>% map(extractor) %>% unlist %>%
    strsplit(";") %>% map(str_extract, ".*(?=(\\(.+\\)))|.*") %>%
    map(strsplit, ", ") %>% map(unlist) %>% map(keep, is_notnumeric) %>%
    map(translate, hash) %>% map(as.list)
}

# Function to identify the districts name and return a vector of character,
# the extractor parametes permit to select the district names before (1) or
# after (2) the event. Hash for the translation of the district name in a
# standardized format
id_district <- function(vect, extractor, hash_p, hash_d) {
  vect %>% split_event(.) %>% map(extractor) %>% unlist %>%
    strsplit(";") %>% map(strsplit, "[[:digit:]],") %>% map(unlist) %>%
    map(keep, is_notnumeric) %>% flatten() %>%
    data_frame(province = unlist(.)) %>%
    mutate(district = str_extract(province, "\\(.+\\)") %>%
             map(paste, collapse = ", ") %>%
             gsub("\\(|\\)", "", .) %>% strsplit(", ") %>%
             map(translate, hash_d),
           province = str_extract(province, ".*(?=(\\(.+\\)))|.*") %>%
             gsub(" in ", "", .) %>%
             map(translate, hash_p) %>% unlist) %>%
    select(province, district) %>%
    #tidyr::unnest() %>%
    #mutate(total = paste0(province, "_", district) %>% gsub(".*_NA", NA, .)) %>%
    #select(total) %>%
    list
  #vect %>%
   # split_event(.) %>% map(extractor) %>% unlist %>%
  #  strsplit(";") %>% map(str_extract, "\\(.+\\)") %>%
  #  map(paste, collapse = ", ") %>% gsub("\\(|\\)", "", .) %>%
  #  strsplit(", ") %>% map(translate, hash) %>% map(as.list) %>% map(na.omit)
}

# From a text file (see prerequisite), make a list of list of 4 elements:
# 'year': date of event in character,
# 'event': character either split, merge or rename,
# 'before': name of the province(s) before the event in a list and
# 'after': name of the province(s) after the event in a list
make_history <-  function(file, hash, d.hash) {

  hist_list <- read.delim(file, header = FALSE)

  df <- mutate(hist_list,
               year = id_date(V1),
               event = id_event(V1),
               before = id_province(V1, 1, hash),
               after = id_province(V1, 2, hash))

  if (any(df$event %>% str_detect("complexe"))) {
    df %<>% mutate(
      d.before = id_district(V1, 1, hash, d.hash),
      d.after = id_district(V1, 2, hash, d.hash))
  }

  df %>%
    select(-V1) %>%
    transpose(.)
}

# Data -------------------------------------------------------------------------

vn_history <- make_history("data-raw/History_txtfile/vn_history.txt",
                           dictionary::vn_province)

th_history <- make_history("data-raw/History_txtfile/th_history.txt",
                           dictionary::th_province)

la_history <- make_history("data-raw/History_txtfile/la_history.txt",
                           dictionary::la_province,
                           dictionary::la_district)

kh_history <- make_history("data-raw/History_txtfile/kh_history.txt",
                           dictionary::kh_province)

# Writing to disk --------------------------------------------------------------

devtools::use_data(vn_history, th_history, la_history, kh_history,
                   overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
