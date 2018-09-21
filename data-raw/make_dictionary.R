library(dplyr) # for "filter", "mutate", "select"
library(magrittr) # for "%>%", "%<>%"

# INFORMATION ------------------------------------------------------------------

# We use the name of the province given by GADM without accent or special
# character as translation.
# Source : gadm: https://gadm.org

# To complete our dictionary with different variation of name, we also include
# the data by country coming from the geonames website:
# Source: http://download.geonames.org/export/dump/

# FUNCTIONS --------------------------------------------------------------------

# Read geonames country files, add the column names and mutate the column
# containing the province names in character
read_geonames <- function(file) {

  geo_df <- read.delim(file, header = FALSE)
  colnames(geo_df) <- c("geonameid", "name", "asciiname", "alternatenames",
                        "latitude", "longitude", "f_class", "f_code",
                        "country_code", "cc2", "admin1_code", "admin2_code",
                        "admin3_code", "admin4_code", "population", "elevation",
                        "dem", "timezone", "data_modif")

  geo_df %<>% filter(f_code == "ADM1") %>%
    mutate(name = as.character(name),
           asciiname = as.character(asciiname),
           alternatenames = as.character(alternatenames))
}

# Remove the accent, convert the special character to latin and express
# characters in UNICODE.
# (Use in  create_dictionary)
uni_vect <- function(vect) {
  vect %<>%
    as.character() %>%
    mcutils::vn2latin() %>%                   # Convert the special character
    iconv(., to = "ASCII//TRANSLIT") %>%        # Convert to ASCII to
    gsub("[^[:alnum:][:space:]-]", "", .) %>%  # remove the accent
    gsub(" pref", "_pref", .) %>%             # Keep "_prefecture" for Vientiane
    gsub("GJ", "D", .) %>%                    # (VN) the "Đ" can be written "GJ"
    gsub("Khoueng | Province|Changwat |Tinh |Thanh Pho |Krong ", "", .)
    # Remove the spatial definition
}

# From a character vector, compile different versions of this character vector:
# express in upper, lower cases or with capital letters at the beginning of each
# word. (Use in vect_version)
vect_case <- function(vect) {
  vect %<>% as.character()
  vect_case <- c(vect, tolower(vect), toupper(vect),
                 stringr::str_to_title(vect))
}

# From a character vector, compile different versions of this character vector:
# express in upper, lower cases, with or without space or "_" or with capital
# letters at the beginning of each word and expressed it in UNICODE.
# (Use in  create_dictionary, alternate_name, add_dictionary, add_transl)
vect_version <- function(vect) {

  vect %<>% as.character()
  vect <- vect_case(vect)
  vect_space <- vect %>% gsub(" ", "", .) %>% vect_case
  vect_ <- vect %>% gsub("_", " ", .) %>% vect_case

  vect_vers <- c(vect, vect_space, vect_) %>%
    na.omit %>%
    unique %>%
    stringi::stri_escape_unicode()

}

# From a data frame, extract the different names in columns (colnames)
# compile all the translation for each name in a vector. The alternates names
# can be stock in or more columns and multiple names can be written in one
# column, the parameters sep is used to spearate these names.
# Takes a data frame (df), a vector of the column names containing the different
# names (colnames) and the character used as separator between the
# different names (sep) as input.
# (Use in create_dictionary)
alternate_name <- function(df, colnames, sep) {

  original_name <-
    select(df, one_of(colnames)) %>% unlist %>% as.character %>%
    strsplit(sep) %>% unlist() %>%
    c(gsub("Khoueng | Prefecture| Province|Changwat |Tinh |Thanh Pho ",
           "", .))

  # In Cambodia, the Kandal province surround Phnom Penh, that's why it
  # is in the list of alternative names for this province but it can bring
  # mistake in our translation as Phnom Penh is also a province in Cambodia.
  if (is_in("asciiname", colnames)) {
    if (df$asciiname == "Kandal") {
      original_name %<>% grep("Phnom Penh", ., value = TRUE, invert = TRUE)
    }
    # Same in thailand with bangkok and Phra Nakhon Si Ayutthaya, closed to each
    # other
    if (df$asciiname == "Phra Nakhon Si Ayutthaya") {
      original_name %<>% grep("Bangkok", ., value = TRUE, invert = TRUE)
    }
  }

  original_name %<>% vect_version
}

# From a data frame (df), extract the name in one column (names_transl) remove
# all accents and replace special character if necessary.
# Extract also all the variation of each name in others columns (names_var, sep
# parameters), and compile all the translation for each name in a named vector.
# To add value to an existing dictionary (as named vector), used the 'hash'
# parameters, it will make sure the province names are consistent and add new
# value to hash.
# Takes a data frame (df), a vector of the column names containing
# the different names (names_transl, names_var) and the character used as
# separator between the different names (sep) as input.
create_dictionary <- function(df, names_transl, names_var,
                              sep = ";", hash = NULL) {

  dictionary <- NULL          # create an empty object

  for (i in seq_along(df[, 1])) {

    # Name in latin
    if (is.null(hash)) {
      transl <- df %>% select(names_transl) %>% .[i, ] %>% uni_vect()
    } else {
      transl <- df %>% select(names_transl) %>% .[i, ] %>%
        uni_vect() %>% hash[.]
    }


    # Compile different versions of the province name
    original_name <- c(alternate_name(df[i, ],
                                      colnames = names_var,
                                      sep = sep),
                       transl %>% vect_version)

    # Create a named vector
    dictionary <- c(dictionary,
                    setNames(rep(transl, length(original_name)),
                             original_name))
  }

  if (is.null(hash) == FALSE) dictionary <- c(hash, dictionary)

  dictionary <- dictionary[which(duplicated(names(dictionary)) == FALSE)] %>%
    .[!is.na(.)]

}

# Function to add new value to a dictionary (named vector _ 'hash').
# 'transl' and 'origin' are two vector containing the orginal version of one or
# multiple names (origin) and each translation (transl). These two vectors
# should be of same length.
# If the parameters 'origin' is NULL, it adds new translation (transl) to a
# dictionary and different version of this translation as origin.
# To add to an existing dictionary (as named vector), 'hash' parameters, will
# make sure the province names are consistent and add new value in the named
# vector 'hash'.
add_dictionary <- function(transl, origin = NULL, hash) {

  if (is.null(origin) == FALSE & length(transl) != length(origin)) {
    stop("'transl' and 'origin' should have the same length")
  }

  dictionary <- NULL

  for (i in seq_along(transl)) {
    if (is.null(origin)) {
      transl_prov <- transl[i] %>% stringi::stri_escape_unicode()
      province_name <- transl[i] %>% vect_version()
    } else {
      transl_prov <- transl[i] %>% stringi::stri_escape_unicode() %>% hash[.]
      province_name <- origin[i] %>% vect_version()
    }


    dictionary <- c(dictionary,
                    setNames(rep(transl_prov, length(province_name)),
                             province_name))
  }

  dictionary <- c(hash, dictionary)
  dictionary <- dictionary[which(duplicated(names(dictionary)) == FALSE)] %>%
    .[!is.na(.)]
}


# FOR LAOS ---------------------------------------------------------------------

la_province <- readRDS("data-raw/gadm_data/gadm36_LAO_1_sf.rds") %>%
  create_dictionary(names_transl = "NAME_1",
                    names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                    sep = "\\|") %>%
  create_dictionary(df = read_geonames("data-raw/geonames_data/LA.txt"),
                    names_transl = "asciiname",
                    names_var = c("name", "asciiname", "alternatenames"),
                    sep = ",",
                    hash = .) %>%
  add_dictionary(
    transl = c("Champasak", "Houaphan", "Khammouan", "Phongsali",
             "Xiangkhoang", "Xaisomboun", "Xaisomboun",
             "Xaisomboun", "Xaisomboun",
             "Vientiane_prefecture", "Vientiane_prefecture", "Phongsali",
             "Louang Namtha", "Oudomxai", "Bokeo", "Louangphrabang", "Houaphan",
             "Xaignabouri", "Xiangkhoang", "Vientiane", "Bolikhamxai",
             "Khammouan", "Savannakhet", "Saravan", "Xekong", "Champasak",
             "Attapu", "Attapu", "Vientiane_prefecture", "Xaisomboun",
             "Vientiane_prefecture", "Vientiane_prefecture",
             "Vientiane_prefecture", "Vientiane", "Vientiane_prefecture"),
    origin = c("champasack", "houaphanh", "khammuane", "phongsay",
               "xiengkuang", "special zone", "specialzone",
               "xaysomboun special region", "xaysombounspecialregion",
               "VIENTIANE MUNICIPALITY", "vct", "psl",
               "lnt", "odx", "bk", "lpb", "hp",
               "xyb", "xk", "vp", "blx",
               "km", "svk", "srv", "sk", "cps",
               "atp", "att", "The Capital", "Special zone",
               "The Capital City", "Vientiane Capital",
               "Vientiane M", "Vientiane P", "vientiane city"), .) %>%
  create_dictionary(df = read.csv(
    "data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv") %>%
      filter(CountryName == "LAO PEOPLE'S DEMOCRATIC REPUBLIC"),
    names_transl = "Admin1Name_Preferred",
    names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
    hash = .)


la_district <- readRDS("data-raw/gadm_data/gadm36_LAO_2_sf.rds") %>%
  create_dictionary(names_transl = "NAME_2",
                    names_var = c("NAME_2", "VARNAME_2", "HASC_2"),
                    sep = "\\|") %>%
  add_dictionary(
    transl = c("Longsane", "Thathom"),
    origin = c("Longsan", "Thathon"), .)

# FOR THAILAND -----------------------------------------------------------------

th_province <- readRDS("data-raw/gadm_data/gadm36_THA_1_sf.rds") %>%
  create_dictionary(names_transl = "NAME_1",
                    names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                    sep = "\\|") %>%
  create_dictionary(df = read_geonames("data-raw/geonames_data/TH.txt"),
                    names_transl = "asciiname",
                    names_var = c("name", "asciiname", "alternatenames"),
                    sep = ",",
                    hash = .) %>%
  add_dictionary(transl = c("Prathum Thani", "Phra Nakhon", "Thon Buri"),
                 hash = .)  %>%
  create_dictionary(df = read.csv(
    "data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv") %>%
      filter(CountryName == "THAILAND"),
    names_transl = "Admin1Name_Preferred",
    names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
    hash = .)


# FOR CAMBODIA -----------------------------------------------------------------

kh_province <-  readRDS("data-raw/gadm_data/gadm36_KHM_1_sf.rds") %>%
  create_dictionary(names_transl = "NAME_1",
                    names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                    sep = "\\|") %>%
  add_dictionary(
    transl = c("Otdar Mean Chey", "Tbong Khmum"),
    origin = c("Otar Meanchey", "Tboung Khmum"), .)  %>%
  create_dictionary(df = read_geonames("data-raw/geonames_data/KH.txt"),
                    names_transl = "asciiname",
                    names_var = c("name", "asciiname", "alternatenames"),
                    sep = ",",
                    hash = .) %>%
  add_dictionary(
    transl = c("Banteay Meanchey", "Preah Sihanouk", "Preah Sihanouk",
             "Preah Sihanouk", "Kampong Chhnang", "Otdar Mean Chey",
             "Otdar Mean Chey", "Kampong Chhnang", "Kep",
             "Otdar Mean Chey", "Pailin", "Phnom Penh", "Siemreab",
             "Stoeng Treng", "Otdar Mean Chey"),
    origin = c("b.meanchey", "k preah sihanouk", "k.pr.sihaknouk",
               "k.preahsihaknouk", "kg.chhnang", "o.meanchey",
               "oddor meanchey", "kompong chhnang", "krong kep",
               "oddar mean chey", "paillin", "phom penh", "siam reap",
               "steung treng", "ŎTDÂR MÉANCHEY"), .) %>%
  create_dictionary(df = read.csv(
    "data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv") %>%
      filter(CountryName == "CAMBODIA"),
    names_transl = "Admin1Name_Preferred",
    names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
    hash = .)

# FOR VIETNAM ------------------------------------------------------------------

vn_province <- readRDS("data-raw/gadm_data/gadm36_VNM_1_sf.rds") %>%
  create_dictionary(names_transl = "NAME_1",
                    names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                    sep = "\\|") %>%
  add_dictionary(
    transl = c("Ba Ria - Vung Tau", "Ho Chi Minh"),
    origin = c("Ba Ria-Vung Tau", "Ho Chi Minh City"), .) %>%
  create_dictionary(df = read_geonames("data-raw/geonames_data/VN.txt"),
                    names_transl = "asciiname",
                    names_var = c("name", "asciiname", "alternatenames"),
                    sep = ",",
                    hash = .) %>%
  add_dictionary(transl =
                c("Bac Thai", "Binh Tri Thien", "Cuu Long", "Gia Lai - Kon Tum",
                  "Ha Bac", "Ha Nam Ninh", "Ha Son Binh", "Ha Tuyen",
                  "Hai Hung", "Hoang Lien Son", "Minh Hai", "Nghe Tinh",
                  "Nghia Binh", "Phu Khanh", "Quang Nam - Da Nang", "Song Be",
                  "Thuan Hai", "Vinh Phu", "Ha Tay", "Nam Ha", "Dack Lak"),
               hash = .) %>%
  create_dictionary(df = read.table("data-raw/vietnam/provinces.txt",
                                    sep = ";", header = TRUE,
                                    stringsAsFactors = FALSE),
                    names_transl = "new",
                    names_var = "old",
                    hash = .)  %>%
  add_dictionary(
    transl = c("Quang Nam - Da Nang", "Thua Thien Hue", "Ho Chi Minh",
             "Ba Ria - Vung Tau"),
    origin = c("Q. NAM-DA NANG", "THUA THIEN - HUE", "TP. HO CHI MINH",
               "VUNG TAU - BA RIA"), .) %>%
  create_dictionary(df = read.csv(
    "data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv") %>%
      filter(CountryName == "VIET NAM"),
    names_transl = "Admin1Name_Preferred",
    names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
    hash = .)

vn_district <- readRDS("data-raw/gadm_data/gadm36_VNM_2_sf.rds") %>%
  create_dictionary(names_transl = "NAME_2",
                    names_var = c("NAME_2", "VARNAME_2", "HASC_2"),
                    sep = "\\|") %>%
  create_dictionary(df = read.table("data-raw/vietnam/districts.txt",
                                    sep = ";", header = TRUE,
                                    stringsAsFactors = FALSE),
                    names_transl = "new",
                    names_var = "old",
                    hash = .)

# Writing to disk --------------------------------------------------------------

devtools::use_data(kh_province, la_province, th_province,
                   vn_province, vn_district, la_district,
                   overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
