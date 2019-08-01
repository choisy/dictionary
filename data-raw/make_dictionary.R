library(stringi) # for "stri_trans_general", "stri_trans_totitle",
# "stri_escape_unicode"

# INFORMATION ------------------------------------------------------------------

# We use the name of the admin1 given by GADM without accent or special
# character as translation.
# Source : gadm: https://gadm.org

# To complete our dictionary with different variation of name, we also include
# the data by country coming from the geonames website:
# Source: http://download.geonames.org/export/dump/

# FUNCTIONS -------------------------------------------------------------------

# Download geonames files, read the txt file and remove alll the files
# downloaded
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

# Read geonames country output files, add the column names and mutate the column
# containing the admin1 names in character
tidy_geonames <- function(geo_df) {
  colnames(geo_df) <- c("geonameid", "name", "asciiname", "alternatenames",
                        "latitude", "longitude", "f_class", "f_code",
                        "country_code", "cc2", "admin1_code", "admin2_code",
                        "admin3_code", "admin4_code", "population", "elevation",
                        "dem", "timezone", "data_modif")
  geo_df <- geo_df[which(geo_df$f_code == "ADM1"), ]
  geo_df <- transform(geo_df,
                      name = as.character(name),
                      asciiname = as.character(asciiname),
                      alternatenames = as.character(alternatenames))
}

# Remove the accent, convert the special character to latin and express
# characters in ASCII.
# (Use in  create_dictionary)
uni_vect <- function(vect) {
  vect <- as.character(vect)
  # Convert to ASCII to remove the occent
  vect <- stringi::stri_trans_general(vect, "latin-ascii")
  vect <-  gsub("[^[:alnum:][:space:]-]", "", vect) # remove the accent
  vect <- gsub(" pref", "_pref", vect) # Keep "_prefecture" for Vientiane
  vect <- gsub("GJ", "D", vect) # (VN) the "Đ" can be written "GJ"
  gsub("Khoueng | Province|Changwat |Tinh |Thanh Pho |Krong ", "", vect)
}

# From a character vector, compile different versions of this character vector:
# express in upper, lower cases or with capital letters at the beginning of each
# word. (Use in vect_version)
vect_case <- function(vect) {
  vect <- as.character(vect)
  vect_case <- c(vect, tolower(vect), toupper(vect),
                 stringi::stri_trans_totitle(vect))
}

# From a character vector, compile different versions of this character vector:
# express in upper, lower cases, with or without space or "_" or with capital
# letters at the beginning of each word and expressed it in UNICODE.
# (Use in  create_dictionary, alternate_name, add_dictionary, add_transl)
vect_version <- function(vect) {
  vect <- vect_case(vect)
  vect_space <- vect_case(gsub(" ", "", vect))
  vect_ <- vect_case(gsub("_", " ", vect))
  ascii_vect <- stringi::stri_trans_general(vect, "latin-ascii")
  vect_vers <- unique(na.omit(c(vect, vect_space, vect_, ascii_vect)))
  vect_vers <- stringi::stri_escape_unicode(vect_vers)
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

# From a data frame (df), extract the name in one column (names_transl) remove
# all accents and replace special character if necessary.
# Extract also all the variation of each name in others columns (names_var, sep
# parameters), and compile all the translation for each name in a named vector.
# To add value to an existing dictionary (as named vector), used the 'hash'
# parameters, it will make sure the admin1 names are consistent and add new
# value to hash.
# Takes a data frame (df), a vector of the column names containing
# the different names (names_transl, names_var) and the character used as
# separator between the different names (sep) as input.
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

# Function to add new value to a dictionary (named vector _ 'hash').
# 'transl' and 'origin' are two vector containing the orginal version of one or
# multiple names (origin) and each translation (transl). These two vectors
# should be of same length.
# If the parameters 'origin' is NULL, it adds new translation (transl) to a
# dictionary and different version of this translation as origin.
# To add to an existing dictionary (as named vector), 'hash' parameters, will
# make sure the admin1 names are consistent and add new value in the named
# vector 'hash'.
add_dictionary <- function(transl, origin = NULL, hash) {

  if (is.null(origin) == FALSE & length(transl) != length(origin)) {
    stop("'transl' and 'origin' should have the same length")
  }

  dictionary <- NULL
  for (i in seq_along(transl)) {
    if (is.null(origin)) {
      transl_prov <- stringi::stri_escape_unicode(transl[i])
      admin1_name <- vect_version(transl[i])
    } else {
      transl_prov <- hash[stringi::stri_escape_unicode(transl[i])]
      admin1_name <- vect_version(origin[i])
    }
    dictionary <- c(dictionary, setNames(rep(transl_prov, length(admin1_name)),
                                         admin1_name))
  }

  dictionary <- c(hash, dictionary)
  dictionary <- dictionary[which(duplicated(names(dictionary)) == FALSE)]
  dictionary[!is.na(dictionary)]
}

# FOR LAOS ---------------------------------------------------------------------

la_admin1 <- as.data.frame(sptools::gadm("Laos", "sf", 1),
                           stringsAsFactors = FALSE)
la_admin1 <- create_dictionary(la_admin1, names_transl = "NAME_1",
                    names_var = c("NAME_1", "VARNAME_1", "HASC_1"), sep = "\\|")
la_admin1 <- create_dictionary(
  df = tidy_geonames(read_geonames("LA")),
  names_transl = "asciiname",
  names_var = c("name", "asciiname", "alternatenames"), sep = ",",
  hash = la_admin1)
la_admin1 <- add_dictionary(
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
               "Vientiane M", "Vientiane P", "vientiane city"),
    hash = la_admin1)
df <- read.csv("data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv",
               stringsAsFactors = FALSE)
df <- df[which(df$CountryName == "LAO PEOPLE'S DEMOCRATIC REPUBLIC"), ]
la_admin1 <- create_dictionary(df =  df, names_transl = "Admin1Name_Preferred",
    names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
    hash = la_admin1)

la_admin2 <- as.data.frame(sptools::gadm("Laos", "sf", 2),
                           stringsAsFactors = FALSE)
la_admin2 <- create_dictionary(la_admin2, names_transl = "NAME_2",
                               names_var = c("NAME_2", "VARNAME_2", "HASC_2"),
                               sep = "\\|")
la_admin2 <- add_dictionary(transl = c("Longsane", "Thathom"),
                            origin = c("Longsan", "Thathon"), la_admin2)

# FOR THAILAND -----------------------------------------------------------------

th_admin1 <- as.data.frame(sptools::gadm("Thailand", "sf", 1),
                           stringsAsFactors = FALSE)
th_admin1 <- create_dictionary(th_admin1, names_transl = "NAME_1",
                               names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                               sep = "\\|")
th_admin1 <- create_dictionary(
  df = tidy_geonames(read_geonames("TH")),
  names_transl = "asciiname",
  names_var = c("name", "asciiname", "alternatenames"), sep = ",",
  hash = th_admin1)
th_admin1 <- add_dictionary(
  transl = c("Prathum Thani", "Phra Nakhon", "Thon Buri"), hash = th_admin1)
df <- read.csv("data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv",
               stringsAsFactors = FALSE)
df <- df[which(df$CountryName == "THAILAND"), ]
th_admin1 <- create_dictionary(df = df, names_transl = "Admin1Name_Preferred",
    names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
    hash = th_admin1)

# FOR CAMBODIA -----------------------------------------------------------------

kh_admin1 <- as.data.frame(sptools::gadm("Cambodia", "sf", 1),
                           stringsAsFactors = FALSE)
kh_admin1 <- create_dictionary(kh_admin1, names_transl = "NAME_1",
                               names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                               sep = "\\|")
kh_admin1 <- add_dictionary(
  transl = c("Otdar Mean Chey", "Tbong Khmum"),
  origin = c("Otar Meanchey", "Tboung Khmum"), hash = kh_admin1)
kh_admin1 <- create_dictionary(
  df = tidy_geonames(read_geonames("KH")),
  names_transl = "asciiname",
  names_var = c("name", "asciiname", "alternatenames"), sep = ",",
  hash = kh_admin1)
kh_admin1 <- add_dictionary(
    transl = c("Banteay Meanchey", "Preah Sihanouk", "Preah Sihanouk",
             "Preah Sihanouk", "Kampong Chhnang", "Otdar Mean Chey",
             "Otdar Mean Chey", "Kampong Chhnang", "Kep",
             "Otdar Mean Chey", "Pailin", "Phnom Penh", "Siemreab",
             "Stoeng Treng", "Otdar Mean Chey", "Rotanokiri",
             "Otdar Mean Chey", "Kampong Chhnang"),
    origin = c("b.meanchey", "k preah sihanouk", "k.pr.sihaknouk",
               "k.preahsihaknouk", "kg.chhnang", "o.meanchey",
               "oddor meanchey", "kompong chhnang", "krong kep",
               "oddar mean chey", "paillin", "phom penh", "siam reap",
               "steung treng", "ŎTDÂR MÉANCHEY", "Ratanak Kiri",
               "Otdar Meanchey", "Kampong Chhanang"),
    hash = kh_admin1)
df <- read.csv( "data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv")
df <- df[which(df$CountryName == "CAMBODIA"), ]
kh_admin1 <- create_dictionary(
  df = df, names_transl = "Admin1Name_Preferred",
  names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO"),
  hash = kh_admin1)

# FOR VIETNAM ------------------------------------------------------------------

vn_admin1 <- as.data.frame(sptools::gadm("Vietnam", "sf", 1),
                           stringsAsFactors = FALSE)
vn_admin1 <- create_dictionary(vn_admin1, names_transl = "NAME_1",
                               names_var = c("NAME_1", "VARNAME_1", "HASC_1"),
                               sep = "\\|")
vn_admin1 <- add_dictionary(
  transl = c("Ba Ria - Vung Tau", "Ho Chi Minh"),
  origin = c("Ba Ria-Vung Tau", "Ho Chi Minh City"), hash = vn_admin1)
vn_admin1 <- create_dictionary(
  df = tidy_geonames(read_geonames("VN")),
  names_transl = "asciiname",
  names_var = c("name", "asciiname", "alternatenames"), sep = ",",
  hash = vn_admin1)
vn_admin1 <- add_dictionary(
  transl = c("Bac Thai", "Binh Tri Thien", "Cuu Long", "Gia Lai - Kon Tum",
             "Ha Bac", "Ha Nam Ninh", "Ha Son Binh", "Ha Tuyen", "Hai Hung",
             "Hoang Lien Son", "Minh Hai", "Nghe Tinh", "Nghia Binh",
             "Phu Khanh", "Quang Nam - Da Nang", "Song Be", "Thuan Hai",
             "Vinh Phu", "Ha Tay", "Nam Ha", "Dack Lak"),
  hash = vn_admin1)
vn_admin1 <- create_dictionary(
  df = read.table("data-raw/vietnam/provinces.txt", sep = ";", header = TRUE,
                  stringsAsFactors = FALSE), names_transl = "new",
  names_var = "old", hash = vn_admin1)
vn_admin1 <- add_dictionary(
  transl = c("Quang Nam - Da Nang", "Thua Thien Hue", "Ho Chi Minh",
             "Ba Ria - Vung Tau", "hanoi", "ha giang", "cao bang",
             "tuyen quang", "lao cai", "lai chau", "son la", "yen bai",
             "hoa binh", "thai nguyen", "lang son", "quang ninh", "bac giang",
             "phu tho", "hai duong", "hai phong", "hung yen", "thanh hoa",
             "nghe an", "quang binh", "quang tri", "da nang", "quang nam",
             "quang ngai", "phu yen", "khanh hoa", "kon tum", "gia lai",
             "dak lak", "dak nong", "lam dong", "binh phuoc", "tay ninh",
             "binh duong", "dong nai", "ba ria vung tau", "ho chi minh",
             "long an", "tien giang", "vinh long", "dong thap", "an giang",
             "kien giang", "can tho", "hau giang", "soc trang", "bac lieu"),
    origin = c("Q. NAM-DA NANG", "THUA THIEN - HUE", "TP. HO CHI MINH",
               "VUNG TAU - BA RIA", "han i", "ha ian ", "ca  ban ",
               "tu en uan ", "a  cai", "ai chau", "s n a", "en bai", "h a binh",
               "thai n u en", "an  s n", "uan  ninh", "bac ian ", "phu th ",
               "hai du n ", "hai ph n ", "hun  en", "thanh h a", "n he an",
               "uan  binh", "uan  tri", "da nan ", "uan  nam", "uan  n ai",
               "phu en", "khanh h a", "k n tum", "ia ai", "dak ak", "dak n n ",
               "am d n ", "binh phu c", "ta  ninh", "binh du n ", "d n  nai",
               "ba ria vun  tau", "h  chi minh", "n  an", "tien ian ",
               "vinh n ", "d n  thap", "an ian ", "kien ian ", "can th ",
               "hau ian ", "s c tran ", "bac ieu"), hash = vn_admin1)
df <- read.csv( "data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8.csv",
                stringsAsFactors = FALSE)
df <- df[which(df$CountryName == "VIET NAM"), ]
vn_admin1 <- create_dictionary(df, names_transl = "Admin1Name_Preferred",
                               names_var = c("Admin1Name", "Admin1ISO",
                                             "Admin1Name_Preferred"),
                               hash = vn_admin1)

vn_admin2 <- as.data.frame(sptools::gadm("Vietnam", "sf", 2),
                           stringsAsFactors = FALSE)
vn_admin2 <- create_dictionary(vn_admin2, names_transl = "NAME_2",
                    names_var = c("NAME_2", "VARNAME_2", "HASC_2"),
                    sep = "\\|")
vn_admin2 <- create_dictionary(
  df = read.table("data-raw/vietnam/districts.txt", sep = ";", header = TRUE,
                  stringsAsFactors = FALSE),
  names_transl = "new", names_var = "old", hash = vn_admin2)

# Country ----------------------------------------------------------------------

SEA_country <- setNames(
  c("Cambodia", "Laos", "Thailand", "Vietnam"),
  c("CAMBODIA", "LAO PEOPLES DEMOCRATIC REPUBLIC ", "THAILAND", "VIET NAM"))
SEA_country <- create_dictionary(
  read.csv("data-raw/Tycho_data/KH_TH_LA_VN_country_utf8.csv"),
  names_transl = "CountryName_Preferred",
  names_var = c("CountryISO", "CountryName", "CountryName_Preferred"),
  hash = SEA_country)


# South East Asia ISO ----------------------------------------------------------

ISO_admin1 <- create_dictionary(
  read.csv("data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8_epix.csv"),
  names_transl = "Admin1ISO",
  names_var = c("Admin1Name", "epix", "Admin1Name_Preferred", "Admin1ISO"))
ISO_admin1 <- add_dictionary(
    transl = c("KH-22", "LA-VT", "TH-14"),
    origin = c("Kep", "Vientiane_prefecture", "Phra Nakhon Si Ayutthaya"),
    hash = ISO_admin1)

ISO_country <- create_dictionary(
  read.csv("data-raw/Tycho_data/KH_TH_LA_VN_country_utf8.csv"),
  names_transl = "CountryISO",
  names_var = c("CountryISO", "CountryName", "CountryName_Preferred"))

# Writing to disk --------------------------------------------------------------

usethis::use_data(kh_admin1, la_admin1, th_admin1,
                   vn_admin1, vn_admin2, la_admin2,
                   SEA_country, ISO_country, ISO_admin1,
                   overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
