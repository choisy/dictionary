#' Vietnamese admin3 dictionary
#'
#' A names charactor vector containing the translation from Vietnamese to
#' English of the admin3 names in Vietnamese.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(admin3)
#'
#' @format An object of class \code{character} of length 80621.
"admin3"

#' Vietnamese admin2 units dictionary
#'
#' A names charactor vector containing the translation from Vietnamese to
#' English of the admin2 units names in Vietnamese.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(vn_admin2)
#'
#' @format An object of class \code{character} of length 21158.
"vn_admin2"

#' Lao admin2 units dictionary
#'
#' A names charactor vector containing the translation from Lao to
#' English of the admin2 units names in Vietnamese.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(la_admin2)
#'
#' @format An object of class \code{character} of length 1632.
"la_admin2"

#' Vietnamese admin1 unit dictionary
#'
#' A named character vector containing the translation in English of the
#' admin1 unit names in Vietnam.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(vn_admin1)
#'
#' @format An object of class \code{character} of length 5539.
"vn_admin1"

#' Lao admin1 unit dictionary
#'
#' A named character vector containing the translation in English of the
#' admin1 unit names in Laos.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(la_admin1)
#'
#' @format An object of class \code{character} of length 1353.
"la_admin1"

#' Cambodian admin1 unit dictionary
#'
#'A named character vector containing the translation in English of the
#' admin1 unit names in Cambodia.
#' The dictionary is encoded in UNICODE
#'
#' @usage data(kh_admin1)
#'
#' @format An object of class \code{character} of length 3812.
"kh_admin1"

#' Thai admin1 unit dictionary
#'
#'A named character vector containing the translation in English of the
#' admin1 unit names in Thailand.
#'
#' @usage data(th_admin1)
#'
#' @format An object of class \code{character} of length 3275.
"th_admin1"

#' ISO admin1 unit dictionary
#'
#'A named character vector containing the translation in ISO code 3166-66 of the
#' admin1 unit names of South East Asia country.
#'
#' @usage data(ISO_admin1)
#'
#' @format An object of class \code{character} of length 2357.
"ISO_admin1"

#' ISO Countries dictionary
#'
#'A named character vector containing the translation in ISO code 3166-66 of the
#' country names of South East Asia.
#'
#' @usage data(ISO_country)
#'
#' @format An object of class \code{character} of length 41.
"ISO_country"

#' SEA Countries dictionary
#'
#'A named character vector containing the translation in English of the
#' country names of South East Asia.
#'
#' @usage data(SEA_country)
#'
#' @format An object of class \code{character} of length 42.
"SEA_country"

#' Vietnamese admin1 unit By Year
#'
#' A list of charactor vector containing the English names of the admin1 unit
#' ordered by year.
#'
#' One specificity of Vietnam is the splits of administrative admin1 unit during
#' its history, starting from 40 admin1 unit in 1980 and ending with 63 admin1 unit
#' since 2008. This list contains for each of change, the name of the "new"
#' admin1 unit in English.
#'
#' @usage data(vn_admin1_year)
#'
#' @format An object of class \code{list} of length 7.
#'  \itemize{
#'    \item \code{"1979-1990"}: character vector of the 40 admin1 unit in English
#'    \item \code{"1990-1991"}: character vector of the 44 admin1 unit in English
#'    \item \code{"1991-1992"}: character vector of the 45 admin1 unit in English
#'    \item \code{"1992-1997"}: character vector of the 53 admin1 unit in English
#'    \item \code{"1997-2004"}: character vector of the 61 admin1 unit in English
#'    \item \code{"2004-2008"}: character vector of the 64 admin1 unit in English
#'    \item \code{"2008-2020"}: character vector of the 63 admin1 unit in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(vn_admin1_year)
#'
#' # To have the names of the admin1, between 1992 and 1997:
#' vn_admin1_year$`1992`
#'
"vn_admin1_year"

#' Cambodian admin1 unit By Year
#'
#' A list of charactor vector containing the English names of the admin1 unit
#' ordered by year. This list contains for each of change, the name of the "new"
#' admin1 unit in English.
#'
#' @usage data(kh_admin1_year)
#'
#' @format An object of class \code{list} of length 3.
#'  \itemize{
#'    \item \code{"1994-1997"}: character vector of the 23 admin1 unit in English
#'    \item \code{"1997-2013"}: character vector of the 24 admin1 unit in English
#'    \item \code{"2013-2020"}: character vector of the 25 admin1 unit in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(kh_admin1_year)
#'
#' # To have the names of the admin1, between 1992 and 1997:
#' kh_admin1_year$`1994`
#'
"kh_admin1_year"

#' Thai admin1 unit By Year
#'
#' A list of charactor vector containing the English names of the admin1 unit
#' ordered by year. This list contains for each of change, the name of the "new"
#' admin1 unit in English.
#'
#' @usage data(th_admin1_year)
#'
#' @format An object of class \code{list} of length 7.
#'  \itemize{
#'    \item \code{"1967-1972"}: character vector of the 71 admin1 unit in English
#'    \item \code{"1972-1977"}: character vector of the 71 admin1 unit in English
#'    \item \code{"1977-1981"}: character vector of the 72 admin1 unit in English
#'    \item \code{"1981-1982"}: character vector of the 72 admin1 unit in English
#'    \item \code{"1982-1993"}: character vector of the 73 admin1 unit in English
#'    \item \code{"1993-2011"}: character vector of the 76 admin1 unit in English
#'    \item \code{"2011-2020"}: character vector of the 77 admin1 unit in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(th_admin1_year)
#'
#' # To have the names of the admin1, between 1993 and 2011:
#' th_admin1_year$`1993`
#'
"th_admin1_year"

#' Lao admin1 unit By Year
#'
#' A list of charactor vector containing the English names of the admin1 unit
#' ordered by year. This list contains for each of change, the name of the "new"
#' admin1 unit in English.
#'
#' @usage data(la_admin1_year)
#'
#' @format An object of class \code{list} of length 3.
#'  \itemize{
#'    \item \code{"1997-2006"}: character vector of the 18 admin1 unit in English
#'    \item \code{"2006-2013"}: character vector of the 17 admin1 unit in English
#'    \item \code{"2013-2020"}: character vector of the 18 admin1 unit in English
#' }
#'
#' @examples
#' # To have the year of each events of splitting/merging:
#' names(la_admin1_year)
#'
#' # To have the names of the admin1, between 1997 and 2006:
#' la_admin1_year$`1997`
#'
"la_admin1_year"

#' Vietnamese admin1 unit Boundaries History (since 1979)
#'
#' List of 24 lists containing 4 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge or
#'    rename
#'    \item \code{before}: list of name of the admin1(s) before the event
#'    \item \code{after}: list of name of the admin1(s) after the event
#' }
#'
#' @usage data(vn_history)
#'
#' @format An object of class \code{list} of length 24.
"vn_history"

#' Thai admin1 unit Boundaries History (since 1972)
#'
#' List of 9 lists containing 4 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge or
#'    rename
#'    \item \code{before}: list of name of the admin1(s) before the event
#'    \item \code{after}: list of name of the admin1(s) after the event
#' }
#'
#' @usage data(th_history)
#'
#' @format An object of class \code{list} of length 9.
"th_history"

#' Lao admin1 unit Boundaries History (since 1993)
#'
#' List of 2 lists containing 6 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge,
#'    complex split, complex merge or rename
#'    \item \code{before}: list of name of the admin1(s) before the event
#'    \item \code{after}: list of name of the admin1(s) after the event
#'    \item \code{d.before}: details of the previous admin2 units in the admin1
#'    associated concerned by the complex event
#'    \item \code{a.before}: details of the admin2 units in the admin1
#'    associated concerned after the complex event
#' }
#'
#' @usage data(la_history)
#'
#' @format An object of class \code{list} of length 2.
"la_history"

#' Cambodia admin1 unit Boundaries History (since 1996)
#'
#' List of 2 lists containing 4 elements:
#'  \itemize{
#'    \item \code{year}: date of event in character in format "YYYY-mm-dd"
#'    \item \code{event}: character vector of one object either split, merge or
#'    rename
#'    \item \code{before}: list of name of the admin1(s) before the event
#'    \item \code{after}: list of name of the admin1(s) after the event
#' }
#'
#' @usage data(kh_history)
#'
#' @format An object of class \code{list} of length 9.
"kh_history"
