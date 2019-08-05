# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
#' Creates a lists of admin1 names by year range
#'
#' From a vector of admin1 name downloaded from GADM, create a list, by year of
#' event (from \code{history_lst}) and by a time ramge (\code{from} and
#' \code{to} parameters), of admin1 names by year of change.
#'
#' @param country string character country name.
#' @param hash named vector used to translate Gadm names in English withot accent
#' @param history_lst list of event (see **_history object and
#'  \code{make_history} function)
#' @param from year in character or numeric
#' @param to year in character or numeric
#'
#' @return a list of named vector, the names are the year of event.
#' @export
#' @examples
#' library(dictionary)
#' la_admin1_year <- list_year_admin1("Laos", la_admin1, la_history,
#'                                    from = "1997")
list_year_admin1 <- function(country, hash, history_lst, from = "1960",
                             to = "2020") {
  # donwload actual province name
  df <- as.data.frame(gadm(country, "sf", 1), stringsAsFactors = FALSE)
  vect <- df[, "NAME_1"]
  vect <- translate(vect, hash)
  vect <- sort(unique(vect))
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
