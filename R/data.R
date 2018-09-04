#' Vietnamese Communes dictionary
#'
#' A names charactor vector containing the translation from Vietnamese to
#' English of the communes names in Vietnamese.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(communes)
#'
#' @format An object of class \code{character} of length 80621.
"communes"

#' Vietnamese Districts dictionary
#'
#' A names charactor vector containing the translation from Vietnamese to
#' English of the districts names in Vietnamese.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(districts)
#'
#' @format An object of class \code{character} of length 3406.
"districts"

#' Vietnamese Provinces dictionary
#'
#' A named character vector containing the translation in English of the
#' provinces names in Vietnam.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(vn_province)
#'
#' @format An object of class \code{character} of length 5013.
"vn_province"

#' Lao Provinces dictionary
#'
#' A named character vector containing the translation in English of the
#' provinces names in Laos.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(la_province)
#'
#' @format An object of class \code{character} of length 1195.
"la_province"

#' Cambodian Provinces dictionary
#'
#'A named character vector containing the translation in English of the
#' provinces names in Cambodia.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(kh_province)
#'
#' @format An object of class \code{character} of length 3687.
"kh_province"

#' Thai Provinces dictionary
#'
#'A named character vector containing the translation in English of the
#' provinces names in Thailand.
#'
#' @usage data(th_province)
#'
#' @format An object of class \code{character} of length 3029.
"th_province"

#' Vietnamese Provinces By Year
#'
#' A list of charactor vector containing the English names of the provinces
#' names in Vietnamese ordered by year.
#'
#' One specificity of Vietnam is the splits of administrative provinces during
#' its history, starting from 40 provinces in 1980 and ending with 63 provinces
#' since 2008. This list contains for each of change, the name of the "new"
#' provinces in English.
#'
#' @usage data(province_year)
#'
#' @format An object of class \\code{list} of length 7.
#'  \itemize{
#'    \item \code{1979}: character vector of the 40 provinces in English
#'    \item \code{1990}: character vector of the 44 provinces in English
#'    \item \code{1991}: character vector of the 45 provinces in English
#'    \item \code{1992}: character vector of the 53 provinces in English
#'    \item \code{1997}: character vector of the 61 provinces in English
#'    \item \code{2004}: character vector of the 64 provinces in English
#'    \item \code{2008}: character vector of the 63 provinces in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(province_year)
#'
#' # To have the names of the province, between 1992 and 1997:
#' province_year$`1992`
#'
"vn_province_year"
