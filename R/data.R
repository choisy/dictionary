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
#' @usage data(vn_district)
#'
#' @format An object of class \code{character} of length 21158.
"vn_district"

#' Lao Districts dictionary
#'
#' A names charactor vector containing the translation from Lao to
#' English of the districts names in Vietnamese.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(la_district)
#'
#' @format An object of class \code{character} of length 1626.
"la_district"

#' Vietnamese Provinces dictionary
#'
#' A named character vector containing the translation in English of the
#' provinces names in Vietnam.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(vn_province)
#'
#' @format An object of class \code{character} of length 5212.
"vn_province"

#' Lao Provinces dictionary
#'
#' A named character vector containing the translation in English of the
#' provinces names in Laos.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(la_province)
#'
#' @format An object of class \code{character} of length 1346.
"la_province"

#' Cambodian Provinces dictionary
#'
#'A named character vector containing the translation in English of the
#' provinces names in Cambodia.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(kh_province)
#'
#' @format An object of class \code{character} of length 3791.
"kh_province"

#' Thai Provinces dictionary
#'
#'A named character vector containing the translation in English of the
#' provinces names in Thailand.
#'
#' @usage data(th_province)
#'
#' @format An object of class \code{character} of length 3275.
"th_province"

#' Vietnamese Provinces By Year
#'
#' A list of charactor vector containing the English names of the provinces
#' ordered by year.
#'
#' One specificity of Vietnam is the splits of administrative provinces during
#' its history, starting from 40 provinces in 1980 and ending with 63 provinces
#' since 2008. This list contains for each of change, the name of the "new"
#' provinces in English.
#'
#' @usage data(vn_province_year)
#'
#' @format An object of class \code{list} of length 7.
#'  \itemize{
#'    \item \code{"1979-1990"}: character vector of the 40 provinces in English
#'    \item \code{"1990-1991"}: character vector of the 44 provinces in English
#'    \item \code{"1991-1992"}: character vector of the 45 provinces in English
#'    \item \code{"1992-1997"}: character vector of the 53 provinces in English
#'    \item \code{"1997-2004"}: character vector of the 61 provinces in English
#'    \item \code{"2004-2008"}: character vector of the 64 provinces in English
#'    \item \code{"2008-2020"}: character vector of the 63 provinces in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(vn_province_year)
#'
#' # To have the names of the province, between 1992 and 1997:
#' vn_province_year$`1992`
#'
"vn_province_year"

#' Cambodian Provinces By Year
#'
#' A list of charactor vector containing the English names of the provinces
#' ordered by year. This list contains for each of change, the name of the "new"
#' provinces in English.
#'
#' @usage data(kh_province_year)
#'
#' @format An object of class \code{list} of length 3.
#'  \itemize{
#'    \item \code{"1994-1997"}: character vector of the 23 provinces in English
#'    \item \code{"1997-2013"}: character vector of the 24 provinces in English
#'    \item \code{"2013-2020"}: character vector of the 25 provinces in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(kh_province_year)
#'
#' # To have the names of the province, between 1992 and 1997:
#' kh_province_year$`1994`
#'
"kh_province_year"

#' Thai Provinces By Year
#'
#' A list of charactor vector containing the English names of the provinces
#' ordered by year. This list contains for each of change, the name of the "new"
#' provinces in English.
#'
#' @usage data(th_province_year)
#'
#' @format An object of class \code{list} of length 7.
#'  \itemize{
#'    \item \code{"1967-1972"}: character vector of the 71 provinces in English
#'    \item \code{"1972-1977"}: character vector of the 71 provinces in English
#'    \item \code{"1977-1981"}: character vector of the 72 provinces in English
#'    \item \code{"1981-1982"}: character vector of the 72 provinces in English
#'    \item \code{"1982-1993"}: character vector of the 73 provinces in English
#'    \item \code{"1993-2011"}: character vector of the 76 provinces in English
#'    \item \code{"2011-2020"}: character vector of the 77 provinces in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(th_province_year)
#'
#' # To have the names of the province, between 1993 and 2011:
#' th_province_year$`1993`
#'
"th_province_year"

#' Lao Provinces By Year
#'
#' A list of charactor vector containing the English names of the provinces
#' ordered by year. This list contains for each of change, the name of the "new"
#' provinces in English.
#'
#' @usage data(la_province_year)
#'
#' @format An object of class \code{list} of length 3.
#'  \itemize{
#'    \item \code{"1997-2006"}: character vector of the 18 provinces in English
#'    \item \code{"2006-2013"}: character vector of the 17 provinces in English
#'    \item \code{"2013-2020"}: character vector of the 18 provinces in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(la_province_year)
#'
#' # To have the names of the province, between 1997 and 2006:
#' la_province_year$`1997`
#'
"la_province_year"

#' Vietnamese Provinces Boundaries History (since 1979)
#'
#' List of 24 lists containing 4 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge or
#'    rename
#'    \item \code{before}: list of name of the province(s) before the event
#'    \item \code{after}: list of name of the province(s) after the event
#' }
#'
#' @usage data(vn_history)
#'
#' @format An object of class \code{list} of length 24.
"vn_history"

#' Thai Provinces Boundaries History (since 1972)
#'
#' List of 9 lists containing 4 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge or
#'    rename
#'    \item \code{before}: list of name of the province(s) before the event
#'    \item \code{after}: list of name of the province(s) after the event
#' }
#'
#' @usage data(th_history)
#'
#' @format An object of class \code{list} of length 9.
"th_history"

#' Lao Provinces Boundaries History (since 1993)
#'
#' List of 2 lists containing 6 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge,
#'    complexe split, complexe merge or rename
#'    \item \code{before}: list of name of the province(s) before the event
#'    \item \code{after}: list of name of the province(s) after the event
#'    \item \code{d.before}: details of the previous districts in the province
#'    associated concerned by the complexe event
#'    \item \code{a.before}: details of the districts in the province
#'    associated concerned after the complexe event
#' }
#'
#' @usage data(la_history)
#'
#' @format An object of class \code{list} of length 2.
"la_history"

#' Cambodia Provinces Boundaries History (since 1996)
#'
#' List of 2 lists containing 4 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge or
#'    rename
#'    \item \code{before}: list of name of the province(s) before the event
#'    \item \code{after}: list of name of the province(s) after the event
#' }
#'
#' @usage data(kh_history)
#'
#' @format An object of class \code{list} of length 9.
"kh_history"
