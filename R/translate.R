#' Translates Vector in English Without Accent
#'
#' Translates string vector in English without accent using dictionary created
#' and stored in the package by country and level of administrative boundaries.
#'
#' The functions accepts two types of entry for translation. \cr
#' 1. You can use the \code{country} and \code{level} information to translate
#' vector, but only for Vietnam, Cambodia and Thailand.
#' 2 . You can directly input a named vector in UNICODE containing the
#' translation.
#' If the argument \code{hash} is NULL, the vector will be return encoded in
#' UNICODE.
#'
#' @param vect a string chracter vector.
#' @param hash a named UNICODE vector containing the translation
#' @param country a character name of a country.
#' @param level a numeric, 1 for admin1 (province), 2 for admin2 (district),
#' 3 for city/commune.
#'
#' @importFrom stringi stri_escape_unicode
#' @importFrom countrycode countrycode
#'
#' @return String vector of the same length as input in \code{vect} argument
#' @export
#'
#' @examples
#' # to translate province name of Vietnam in English
#' translate(c("AnGiang", "Ha Noi"), vn_province)
#' # or
#' translate(c("AnGiang", "Ha Noi"), country = "Vietnam", level = 1)
translate <- function(vect, hash, country = NULL, level = NULL) {

  if (missing(hash) & (is.null(country) | is.null(level))) {
    stop(
      "The argument 'hash' or the arguments 'country' & 'level'
      should be inputed")
  }
  if (!is.null(country) & !is.null(level)) {
    # get correct dictionary
    country <- countrycode::countrycode(country, "country.name", "iso2c")
    country <- tolower(country)
    if (!country %in% c("vn", "th", "la", "vn")) {
      stop("The arguments 'country' & 'level' can only be used for
           Cambodia, Laos, Thailand and Vietnam")
    }
    # extract level
    nlev <- c("province" = 1, "district" = 2, "commune" = 3)
    level <- names(nlev)[level]
    hash <- get(paste0(country, "_", level))
  }
  # translates vect in UNICODE
  vect <-  stringi::stri_escape_unicode(vect)
  if (!is.null(hash)) vect <- hash[vect]
  vect <- as.character(vect)
  vect
}
