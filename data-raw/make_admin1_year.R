# Packages and System ----------------------------------------------------------
library(dictionary)  # for "translate"

# Prerequisite -----------------------------------------------------------------

# Dictionary translate:
data(la_admin1)
data(kh_admin1)
data(th_admin1)
data(vn_admin1)

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
  sel0 <- as.Date(sapply(hist_lst, "[[", "year"))
  sel0 <- sel0 > as.Date(paste0(from, "-01-01")) &
    sel0 <= as.Date(paste0(to, "-12-31"))
  event_lst <- hist_lst[sel0]
  event_lst[order(sapply(event_lst, "[[", "year"), decreasing = TRUE)]
}

# From a time frame inputed in the function with the parameters `from` and `to`,
# recreate vector of admin1 names of oldest event.
old_vect <- function(vect, history_lst, from, to) {
  # Select event
  event_lst <- select_events(history_lst, from = from, to = to)
  if (length(event_lst) != 0) {
    # Recreate admin1 list
    for (i in seq_along(event_lst)) {
      # select one event
      event <- event_lst[[i]]
      if (grepl("complex split", event$event)) {
        vect <- unlist(c(vect, event$before, event$after))
        vect <- unique(vect)
      } else {
        vect <-  grep(paste0(event$after, collapse = "|"), vect, value = TRUE,
                      invert = TRUE)
        vect <- unlist(c(vect, event$before))
        vect <- unique(vect)
      }
    }
    vect <- sort(vect)
  } else {
    vect <- unique(as.character(vect))
    vect <- sort(vect)
  }
  vect
}

# From a vector of admin1 name `vect`, create a list, by year of event (from
# `history_lst`) and by a time frame (`from` and `to` parameters), of
# admin1 names by year of change. Returns a list of named vector, the names
# are the year of event.
list_year_admin1 <- function(vect, history_lst, from = "1960", to = "2020") {
  # select the year concerned
  from <-  paste0(from, "-01-01")
  sel_year <- unique(c(sapply(history_lst, "[[", "year"), from))
  sel_year <- sel_year[which(sel_year < to & sel_year >= from)]
  sel_year <- sort(format(as.Date(sel_year), "%Y"))
  # make the list
  total_lst <- lapply(seq_along(sel_year), function (x) {
    old_vect(vect, history_lst, from = sel_year[x], to = to)
  })
  total_lst <- setNames(total_lst,
                        paste(sel_year, c(sel_year[-1], to), sep = "-"))
  total_lst
}

# From the gadm file of level 1 in a RDS format, extract the name of the actual
# admin1 name, translate in English, standardized format
actual_prov <- function(file, hash) {
  df <- readRDS(file)
  vect <- df[, "NAME_1"]
  vect <- translate(vect, hash)
  sort(unique(vect))
}

# Make data --------------------------------------------------------------------

la_actual <- actual_prov("data-raw/gadm_data/gadm36_LAO_1_sf.rds", la_admin1)
kh_actual <- actual_prov("data-raw/gadm_data/gadm36_KHM_1_sf.rds", kh_admin1)
th_actual <- actual_prov("data-raw/gadm_data/gadm36_THA_1_sf.rds", th_admin1)
vn_actual <- actual_prov("data-raw/gadm_data/gadm36_VNM_1_sf.rds", vn_admin1)

la_admin1_year <- list_year_admin1(la_actual, la_history, from = "1997")
kh_admin1_year <- list_year_admin1(kh_actual, kh_history, from = "1994")
th_admin1_year <- list_year_admin1(th_actual, th_history, from = "1967")
vn_admin1_year <- list_year_admin1(vn_actual, vn_history, from = "1979")

# Writing to disk --------------------------------------------------------------

usethis::use_data(la_admin1_year, kh_admin1_year,
                   th_admin1_year, vn_admin1_year, overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
