# Packages and System ----------------------------------------------------------
library(magrittr) # for " %>% ", " %<>% "
library(purrr)    # for "map"

# Prerequisite -----------------------------------------------------------------

# Dictionary translate:
data(la_province)
data(kh_province)
data(th_province)
data(vn_province)

# Dictionary history:
data(la_history)
data(kh_history)
data(th_history)
data(vn_history)

# Functions --------------------------------------------------------------------

# Selects events in a list accordingly to the time frame inputed by the
# parameters `from` and `to` and returns a list of event ordered from the most
# recent to the oldest.
select_events <- function(hist_lst, from, to) {
  sel0 <- map(hist_lst, "year") %>% unlist() %>% as.Date()
  sel0 <- sel0 > as.Date(paste0(from, "-01-01")) &
    sel0 <= as.Date(paste0(to, "-12-31"))
  event_lst <- hist_lst[sel0]
  event_lst[order(sapply(event_lst, "[[", "year"), decreasing = TRUE)]
}

# From a time frame inputed in the function with the parameters `from` and `to`,
# recreate vector of province names of oldest event.
old_vect <- function(vect, history_lst, from, to) {
  # Select event
  event_lst <- select_events(history_lst, from = from, to = to)
  if (length(event_lst) != 0) {
    # Recreate province list
    for (i in seq_along(event_lst)) {
      # select one event
      event <- event_lst[[i]]
      if (grepl("complex merge", event$event)) {
        vect <- vect %>% c(., event$before, event$after) %>% unlist() %>%
          unique()
      } else {
        vect <- vect %>% grep(paste0(event$after, collapse = "|"), .,
                              value = TRUE, invert = TRUE) %>%
          c(., event$before) %>% unlist() %>% unique()
      }
    }
    vect %<>% sort()
  } else {
    vect %>% as.character() %>% unique() %>% sort()
  }
  vect
}

# From a vector of province name `vect`, create a list, by year of event (from
# `history_lst`) and by a time frame (`from` and `to` parameters), of
# province names by year of change. Returns a list of named vector, the names
# are the year of event.
list_year_province <- function(vect, history_lst, from = "1960", to = "2020") {
  # select the year concerned
  from <-  paste0(from, "-01-01")
  sel_year <- history_lst %>% map("year") %>% c(from, .) %>% unlist() %>%
    unique() %>% .[which(. < to & . >= from)] %>% lubridate::year(.)
  # make the list
  total_lst <- lapply(seq_along(sel_year), function (x) {
    old_v <- old_vect(vect, history_lst, from = sel_year[x], to = to)
  }) %>%
    setNames(sel_year %>% paste(c(sel_year[-1], to), sep = "-"))
}

# From the gadm file of level 1 in a RDS format, extract the name of the actual
# province name, translate in English, standardized format
actual_prov <- function(file, hash) {
  vect <- readRDS(file) %>%
    select(NAME_1) %>%
    mutate(province = NAME_1 %>% as.character %>%
             stringi::stri_escape_unicode() %>%
             hash[.]) %>%
    select(province) %>%
    unlist() %>%
    unique() %>%
    sort()
}

# Make data --------------------------------------------------------------------

la_actual <- actual_prov("data-raw/gadm_data/gadm36_LAO_1_sf.rds", la_province)
kh_actual <- actual_prov("data-raw/gadm_data/gadm36_KHM_1_sf.rds", kh_province)
th_actual <- actual_prov("data-raw/gadm_data/gadm36_THA_1_sf.rds", th_province)
vn_actual <- actual_prov("data-raw/gadm_data/gadm36_VNM_1_sf.rds", vn_province)

la_province_year <- list_year_province(la_actual, la_history, from = "1997")
kh_province_year <- list_year_province(kh_actual, kh_history, from = "1994")
th_province_year <- list_year_province(th_actual, th_history, from = "1967")
vn_province_year <- list_year_province(vn_actual, vn_history, from = "1979")

# Writing to disk --------------------------------------------------------------

devtools::use_data(la_province_year, kh_province_year,
                   th_province_year, vn_province_year, overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
