#' Compares one column against patterns
#'
#' \code{match_pattern} compares one column of a data frame against a list of
#' pattern.
#'
#' \code{lst_pattern} can contains multiple vector of pattern. The column
#' selected is compared to each vector contained in the list pattern and
#' return the name of the slot with the vector without any difference.
#'
#' @param df a data frame.
#' @param colname a character string specifying the colonne to compare against
#' the list of pattern.
#' @param lst_pattern a named list of pattern, should contains one or multiple
#' vector. Each slot should be named.
#' @param strict a boolean to indicate if the character string should match only
#' some value in the vector (FALSE) or all values (TRUE) on the list of pattern.
#'
#' @return \code{match_pattern} In case of a matching, the function will return
#' a character vector, if not, it will return NULL
#'
#' @examples
#'
#' # To look at the year of expression of the province in Vietnam from a
#' # gdpm data frame (epidemiologic data from Vietnam)
#' library(gdpm)
#'
#' df <- getid(dengue, from = 1980, to = 1982) # get data for dengue for Vietnam
#' # Allows to check the spatial expression is corresponding to the year
#' match_pattern(df, "province", vn_province_year)
#'
#' @export
#'
match_pattern <- function(df, colname, lst_pattern, strict = TRUE){
  vect <- unlist(df[, colname])
  for (i in seq_along(lst_pattern)) {
    if (length(setdiff(vect, lst_pattern[[i]])) == 0) {
      if (strict == TRUE & length(setdiff(lst_pattern[[i]], vect)) == 0) {
        return(names(lst_pattern[i]))
      } else if (strict == FALSE) {
        return(names(lst_pattern[i]))
      }
    }
  }
}
