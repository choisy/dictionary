#' Translates Vector in English Without Accent
#'
#' Translates string vector in English without accent using dictionary created
#' and stored in the package by country and level of administrative boundaries.
#'
#' @param vect a string chracter vector.
#' @param country a character name of a country.
#' @param level a numeric, 1 for admin1 (province), 2 for admin2 (district),
#' 3 for city/commune.
#'
#' @importFrom stringi stri_escape_unicode
#' @importFrom countrycode countrycode
#'
#' @return String vector of the same length as input in `vect` argument
#' @export
#'
#' @examples
#' # to translate province name of Vietnam in English
#' translate(c("AnGiang", "Ha Noi"), "Vietnam", 1)
translate <- function(vect, country, level){
  # translates vect in UNICODE
  vect <-  stringi::stri_escape_unicode(vect)
  # get correct dictionary
  country <- countrycode::countrycode(country, "country.name", "iso2c") %>%
    tolower
   # extract level
  nlev <- c("province" = 1, "district" = 2, "commune" = 3)
  level <- names(nlev)[level]
  dict <- get(paste0(country, "_", level))
  # translates
  vect <- dict[vect]
  vect
}
