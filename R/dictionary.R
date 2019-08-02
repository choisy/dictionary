# ------------------------------------------------------------------------------
#' Download geonames files, read the txt file and remove alll the files
#' downloaded
#' @importFrom utils download.file read.delim
#' @noRd
read_geonames <- function(country) {
  zipfile <- paste0(country, ".zip")
  txtfile <- paste0(country, ".txt")
  download.file(paste0("http://download.geonames.org/export/dump/", country ,
                       ".zip"), zipfile)
  if (!(file.exists(paste0(country, ".zip")))) {
    stop("The file was not downloaded,",
         " maybe it is a problem of country ISO2 name")
  }
  unzip(zipfile)
  df <- read.delim(txtfile, header = FALSE, stringsAsFactors = FALSE)
  file.remove(zipfile, "readme.txt", txtfile)
  df
}

# ------------------------------------------------------------------------------
#' Read geonames country output files, add the column names and mutate the column
#' containing the admin1 names in character
#' @noRd
tidy_geonames <- function(geo_df, code = "ADM1") {
  colnames(geo_df) <- c("geonameid", "name", "asciiname", "alternatenames",
                        "latitude", "longitude", "f_class", "f_code",
                        "country_code", "cc2", "admin1_code", "admin2_code",
                        "admin3_code", "admin4_code", "population", "elevation",
                        "dem", "timezone", "data_modif")
  geo_df <- geo_df[which(geo_df$f_code == code), ]
  geo_df <- transform(geo_df,
                      name = as.character(name),
                      asciiname = as.character(asciiname),
                      alternatenames = as.character(alternatenames))
}

# ------------------------------------------------------------------------------
#' Remove the accent, convert the special character to latin and express
#' characters in ASCII.
#' @noRd
uni_vect <- function(vect) {
  vect <- as.character(vect)
  # Convert to ASCII to remove the occent
  vect <- stringi::stri_trans_general(vect, "latin-ascii")
  vect <-  gsub("[^[:alnum:][:space:]-]", "", vect) # remove the accent
  vect <- gsub(" pref", "_pref", vect) # Keep "_prefecture" for Vientiane
  vect <- gsub("GJ", "D", vect) # (VN) the "Đ" can be written "GJ"
  gsub("Khoueng | Province|Changwat |Tinh |Thanh Pho |Krong ", "", vect)
}

# ------------------------------------------------------------------------------
#' From a character vector, compile different versions of this character vector:
#' express in upper, lower cases or with capital letters at the beginning of each
#' word.
#' @noRd
#' @importFrom stringi stri_trans_totitle
vect_case <- function(vect) {
  vect <- as.character(vect)
  vect_case <- c(vect, tolower(vect), toupper(vect),
                 stringi::stri_trans_totitle(vect))
}

# ------------------------------------------------------------------------------
#' From a character vector, compile different versions of this character vector:
#' express in upper, lower cases, with or without space or "_" or with capital
#' letters at the beginning of each word and expressed it in UNICODE.
#' @noRd
vect_version <- function(vect) {
  vect <- vect_case(vect)
  vect_space <- vect_case(gsub(" ", "", vect))
  vect_ <- vect_case(gsub("_", " ", vect))
  ascii_vect <- stringi::stri_trans_general(vect, "latin-ascii")
  vect_vers <- unique(na.omit(c(vect, vect_space, vect_, ascii_vect)))
  vect_vers <- stringi::stri_escape_unicode(vect_vers)
}

# ------------------------------------------------------------------------------
#' From a data frame, extract the different names in columns (colnames)
#' compile all the translation for each name in a vector. The alternates names
#' can be stock in or more columns and multiple names can be written in one
#' column, the parameters sep is used to spearate these names.
#' Takes a data frame (df), a vector of the column names containing the different
#' names (colnames) and the character used as separator between the
#' different names (sep) as input.
#' @noRd
alternate_name <- function(df, colnames, sep) {

  ori_name <- unlist(df[, colnames, drop = TRUE])
  ori_name <- unlist(strsplit(as.character(ori_name), sep))
  ori_name <-  c(ori_name, gsub(
    "Khoueng | Prefecture| Province|Changwat |Tinh |Thanh Pho ", "", ori_name))

  # In Cambodia, the Kandal admin1 surround Phnom Penh, that's why it
  # is in the list of alternative names for this admin1 but it can bring
  # mistake in our translation as Phnom Penh is also a admin1 in Cambodia.
  if (any(grepl("asciiname", colnames))) {
    if (df$asciiname == "Kandal") {
      ori_name <-  grep("Phnom Penh", ori_name, value = TRUE, invert = TRUE)
    }
    # Same in thailand with bangkok and Phra Nakhon Si Ayutthaya, closed to each
    # other
    if (df$asciiname == "Phra Nakhon Si Ayutthaya") {
      ori_name <-  grep("Bangkok", ori_name, value = TRUE, invert = TRUE)
    }
  }
  vect_version(ori_name)
}

# ------------------------------------------------------------------------------
#' From a data frame (df), extract the name in one column (names_transl) remove
#' all accents and replace special character if necessary.
#' Extract also all the variation of each name in others columns (names_var, sep
#' parameters), and compile all the translation for each name in a named vector.
#' To add value to an existing dictionary (as named vector), used the 'hash'
#' parameters, it will make sure the admin1 names are consistent and add new
#' value to hash.
#' Takes a data frame (df), a vector of the column names containing
#' the different names (names_transl, names_var) and the character used as
#' separator between the different names (sep) as input.
#' @noRd
create_dictionary <- function(df, names_transl, names_var,
                              sep = ";", hash = NULL) {
  dictionary <- NULL          # create an empty object
  for (i in seq_along(df[, 1])) {
    # Name in latin
    transl <- uni_vect(df[i, names_transl])
    if (!is.null(hash)) transl <- hash[transl]
    # Compile different versions of the admin1 name
    original_name <- c(alternate_name(df[i, ], colnames = names_var, sep = sep),
                       vect_version(transl))
    # Create a named vector
    dictionary <- c(dictionary, setNames(rep(transl, length(original_name)),
                                         original_name))
  }
  if (!is.null(hash)) dictionary <- c(hash, dictionary)

  dictionary <- dictionary[which(duplicated(names(dictionary)) == FALSE)]
  dictionary[!is.na(dictionary)]
}

# ------------------------------------------------------------------------------
#' Creates named vector (use for hashing)
#'
#' From Gadm and Geonames creates a UNICODE dictionary, names vector, with the
#' translation in English without accent.
#'
#' You can create dictionary for different level: 1 (admin1) and 2 (admin2),
#' from the data of GADM and Geonames but you can also add costum value by using
#'  the argument \code{add_dict}. It is also possible to use only the parameter
#'  \code{add_dict} to generate custom dictionary.\cr
#' The variables created are express in upper, lower cases, with or without
#' space or "_" or with capital etters at the beginning of each word and
#' expressed it in UNICODE. \cr
#' Source : gadm: https://gadm.org \cr
#' Source: geonames: http://download.geonames.org/export/dump/
#'
#' @param countryname string character country name
#' @param level numeric level of administrative boundaries (1: admin1,
#'  2: admin2), should be either 1 or 2
#' @param add_dict which contains at least one column \code{translate} (english
#'  without accent) and one or multiple columns containing the tag `var` in the
#'  column names (all this columns will be used to create the possible variable)
#' @param force boolean to force the gadm downlaoding if trouble
#'
#' @importFrom countrycode countrycode
#' @importFrom sptools gadm
#' @importFrom stringi stri_escape_unicode stri_trans_general
#' @export
#' @examples
#' dict_vn <- dictionary("Vietnam", 1)
#' head(dict_vn)
dictionary <- function(countryname, level, add_dict = NULL, force = FALSE) {
  dict <- NULL
  if (!(all(missing(countryname), missing(level)))) {
    if (!(level %in% c(0, 1, 2)))
      stop("level should be a numeric, either 0, 1 or 2.")

    # dict gadm
    df_gadm <- as.data.frame(sptools::gadm(countryname, "sf", level, force),
                             stringsAsFactors = FALSE)
    names_var <- "NAME_0"
    if (level != 0) {
      names_var <- c(paste0("NAME_", level), paste0("VARNAME_", level),
                     paste0("HASC_", level))
    }
    dict <- create_dictionary(df_gadm,
                              names_transl = paste0("NAME_", level),
                              names_var = names_var,
                              sep = "\\|")
  }
  # add custom dict
  if (!(is.null(add_dict))) {
    if (!("data.frame" %in% class(add_dict)))
      stop("add_dict should be a data frame.")
    if (!(any(grepl("var", colnames(add_dict)))))
      stop("add_dict should have at least of column containing 'var'.")
    if (!("translate" %in% colnames(add_dict)))
      stop ("add_dict should have at least one column 'translate'.")
    dict2 <- NULL
    for (i in seq_len(dim(add_dict)[1])) {
      transl <- stringi::stri_escape_unicode(
        stringi::stri_trans_general(add_dict[i, "translate", drop = TRUE],
                                    "latin-ascii"))
      if (!(is.null(dict)))  transl <- ifelse(is.na(dict[transl]), transl,
                                              dict[transl])
      var_n <- vect_version(unlist(add_dict[i, grep("var", names(add_dict))]))
      dict2 <- c(dict2, setNames(rep(transl, length(var_n)), var_n))
    }
    dict <- c(dict2, dict)
    dict <- dict[which(duplicated(names(dict)) == FALSE)]
    dict <- dict[!is.na(dict)]
  }

  # dict geoname (last because needed custom dict to be read sometimes)
  if (!(missing(level))) {
    if (level %in% c(1, 2)) {
      country_iso2c <- countrycode(countryname, "country.name", "iso2c")
      dict <- create_dictionary(
        df = tidy_geonames(read_geonames(country_iso2c), paste0("ADM", level)),
        names_transl = "asciiname",
        names_var = c("name", "asciiname", "alternatenames"), sep = ",",
        hash = dict)
    }
  }
  sort(dict)
}
