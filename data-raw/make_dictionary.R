library(stringi) # for "stri_trans_general", "stri_trans_totitle",
# "stri_escape_unicode"
library(countrycode)

# INFORMATION ------------------------------------------------------------------

# We use the name of the admin1 given by GADM without accent or special
# character as translation.
# Source : gadm: https://gadm.org
# To complete our dictionary with different variation of name, we also include
# the data for admin1 and admin2 by country coming from the geonames website:
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
# (Use in  create_dictionary, alternate_name, add_transl)
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

# ImportFrom countrycode countrycode
# ImportFrom sptools gadm
#
# @param countryname string character country name.
# @param level numeric level of administrative boundaries (1: admin1,
#  2: admin2), should be either 1 or 2.
# @param add_dict which contains at least one column `translate` (english
#  without accent) and one or multiple columns containing the tag `var` in the
#  column names (all this columns will be used to create the dictionary).
# @param force boolean to force the gadm downlaoding if trouble
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

# Prerequisite -----------------------------------------------------------------
df_all <-  read.csv("data-raw/Tycho_data/KH_TH_LA_VN_admin1s_utf8_epix.csv",
                    stringsAsFactors = FALSE)
names_var = c("Admin1Name", "Admin1Name_Preferred", "Admin1ISO")
df_all["translate"] <- as.character(df_all$epix)
names(df_all)[which(names(df_all) %in% names_var)] <- paste0("var_",
                                                           seq_along(names_var))
df_all <- df_all[, which(grepl("var|translate|CountryName", names(df_all)))]


# FOR LAOS ---------------------------------------------------------------------

df_la <- df_all[which(
  df_all$CountryName == "LAO PEOPLE'S DEMOCRATIC REPUBLIC"), ]
df_la2 <- data.frame(
  "translate" = c("Champasak", "Houaphan", "Khammouan", "Phongsali",
                  "Xiangkhoang", "Xaisomboun", "Xaisomboun", "Xaisomboun",
                  "Xaisomboun", "Vientiane_prefecture", "Vientiane_prefecture",
                  "Phongsali", "Louang Namtha", "Oudomxai", "Bokeo",
                  "Louangphrabang", "Houaphan", "Xaignabouri", "Xiangkhoang",
                  "Vientiane", "Bolikhamxai", "Khammouan", "Savannakhet",
                  "Saravan", "Xekong", "Champasak", "Attapu", "Attapu",
                  "Vientiane_prefecture", "Xaisomboun", "Vientiane_prefecture",
                  "Vientiane_prefecture", "Vientiane_prefecture", "Vientiane",
                  "Vientiane_prefecture"),
  "var_1" = c("champasack", "houaphanh", "khammuane", "phongsay", "xiengkuang",
              "special zone", "specialzone", "xaysomboun special region",
              "xaysombounspecialregion", "VIENTIANE MUNICIPALITY", "vct", "psl",
              "lnt", "odx", "bk", "lpb", "hp", "xyb", "xk", "vp", "blx", "km",
              "svk", "srv", "sk", "cps", "atp", "att", "The Capital",
              "Special zone", "The Capital City", "Vientiane Capital",
              "Vientiane M", "Vientiane P", "vientiane city"),
  stringsAsFactors = FALSE)
df_la2[setdiff(names(df_la), names(df_la2))] <- NA
df_la <- rbind(df_la, df_la2)

la_admin1 <- dictionary("Laos", 1, df_la)

la_admin2 <- dictionary("Laos", 2, data.frame(
  "translate" = c("Longsane", "Thathom"), "var" = c("Longsan", "Thathon"),
  stringsAsFactors = FALSE))

# FOR THAILAND -----------------------------------------------------------------

df_th <- df_all[which(df_all$CountryName == "THAILAND"), ]
df_th2 <- data.frame(
  "translate" = c("Prathum Thani", "Phra Nakhon", "Thon Buri"),
  "var_1" = c("Prathum Thani", "Phra Nakhon", "Thon Buri"),
  stringsAsFactors = FALSE)
df_th2[setdiff(names(df_th), names(df_th2))] <- NA
df_th <- rbind(df_th, df_th2)

th_admin1 <- dictionary("Thailand", 1, df_th)

# FOR CAMBODIA -----------------------------------------------------------------

df_kh <- df_all[which(df_all$CountryName == "CAMBODIA"), ]
df_kh2 <- data.frame(
  "translate" = c("Otdar Mean Chey", "Tbong Khmum", "Banteay Meanchey",
                  "Preah Sihanouk", "Preah Sihanouk", "Preah Sihanouk",
                  "Kampong Chhnang", "Otdar Mean Chey", "Otdar Mean Chey",
                  "Kampong Chhnang", "Kep", "Otdar Mean Chey", "Pailin",
                  "Phnom Penh", "Siemreab", "Stoeng Treng", "Otdar Mean Chey",
                  "Rotanokiri", "Otdar Mean Chey", "Kampong Chhnang"),
  "var_1" = c("Otar Meanchey", "Tboung Khmum", "b.meanchey", "k preah sihanouk",
              "k.pr.sihaknouk", "k.preahsihaknouk", "kg.chhnang", "o.meanchey",
              "oddor meanchey", "kompong chhnang", "krong kep",
              "oddar mean chey", "paillin", "phom penh", "siam reap",
              "steung treng", "ŎTDÂR MÉANCHEY", "Ratanak Kiri",
              "Otdar Meanchey", "Kampong Chhanang"),
  stringsAsFactors = FALSE)
df_kh2[setdiff(names(df_kh), names(df_kh2))] <- NA
df_kh <- rbind(df_kh, df_kh2)

kh_admin1 <- dictionary("Cambodia", 1, df_kh)

# FOR VIETNAM ------------------------------------------------------------------

df_vn <- df_all[which(df_all$CountryName == "VIET NAM"), ]
df_vn2 <- data.frame(
  "translate" = c("Ba Ria - Vung Tau", "Ho Chi Minh", "Bac Thai",
                  "Binh Tri Thien", "Cuu Long", "Gia Lai - Kon Tum", "Ha Bac",
                  "Ha Nam Ninh", "Ha Son Binh", "Ha Tuyen", "Hai Hung",
                  "Hoang Lien Son", "Minh Hai", "Nghe Tinh", "Nghia Binh",
                  "Phu Khanh", "Quang Nam - Da Nang", "Song Be", "Thuan Hai",
                  "Vinh Phu", "Ha Tay", "Nam Ha", "Dack Lak",
                  "Quang Nam - Da Nang", "Thua Thien Hue", "Ho Chi Minh",
                  "Ba Ria - Vung Tau", "Ha Noi", "Ha Giang", "Cao Bang",
                  "Tuyen Quang", "Lao Cai", "Lai Chau", "Son La", "Yen Bai",
                  "Hoa Binh", "Thai Nguyen", "Lang Son", "Quang Ninh",
                  "Bac Giang", "Phu Tho", "Hai Duong", "Hai Phong", "Hung Yen",
                  "Thanh Hoa", "Nghe An", "Quang Binh", "Quang Tri", "Da Nang",
                  "Quang Nam", "Quang Ngai", "Phu Yen", "Khanh Hoa", "Kon Tum",
                  "Gia Lai", "Dak Lak", "Dak Nong", "Lam Dong", "Binh Phuoc",
                  "Tay Ninh", "Binh Duong", "Dong Nai", "Ba Ria - Vung Tau",
                  "Ho Chi Minh", "Long An", "Tien Giang", "Vinh Long",
                  "Dong Thap", "An Giang", "Kien Giang", "Can Tho",
                  "Hau Giang", "Soc Trang", "Bac Lieu"),
  "var_1" = c("Ba Ria-Vung Tau", "Ho Chi Minh City", "Bac Thai",
              "Binh Tri Thien", "Cuu Long", "Gia Lai - Kon Tum", "Ha Bac",
              "Ha Nam Ninh", "Ha Son Binh", "Ha Tuyen", "Hai Hung",
              "Hoang Lien Son", "Minh Hai", "Nghe Tinh", "Nghia Binh",
              "Phu Khanh", "Quang Nam - Da Nang", "Song Be", "Thuan Hai",
              "Vinh Phu", "Ha Tay", "Nam Ha", "Dack Lak", "Q. NAM-DA NANG",
              "THUA THIEN - HUE", "TP. HO CHI MINH", "VUNG TAU - BA RIA",
              "han i", "ha ian ", "ca  ban ", "tu en uan ", "a  cai", "ai chau",
              "s n a", "en bai", "h a binh", "thai n u en", "an  s n",
              "uan  ninh", "bac ian ", "phu th ", "hai du n ", "hai ph n ",
              "hun  en", "thanh h a", "n he an", "uan  binh", "uan  tri",
              "da nan ", "uan  nam", "uan  n ai", "phu en", "khanh h a",
              "k n tum", "ia ai", "dak ak", "dak n n ", "am d n ", "binh phu c",
              "ta  ninh", "binh du n ", "d n  nai", "ba ria vun  tau",
              "h  chi minh", "n  an", "tien ian ", "vinh n ", "d n  thap",
              "an ian ", "kien ian ", "can th ", "hau ian ", "s c tran ",
              "bac ieu"),
  stringsAsFactors = FALSE)
df_vn3 <-  read.table("data-raw/vietnam/provinces.txt", sep = ";",
                      header = TRUE, stringsAsFactors = FALSE)

df_vn2[setdiff(names(df_vn), names(df_vn2))] <- NA
df_vn3[setdiff(names(df_vn), names(df_vn3))] <- NA
df_vn <- rbind(df_vn, df_vn2, df_vn3)

vn_admin1 <- dictionary("Vietnam", 1, df_vn)

vn_admin2 <- dictionary("Vietnam", 2,
                        read.table("data-raw/vietnam/districts.txt", sep = ";",
                                   header = TRUE, stringsAsFactors = FALSE))

# Country ----------------------------------------------------------------------
df_country <- read.csv(
  "data-raw/Tycho_data/KH_TH_LA_VN_country_utf8.csv",
  stringsAsFactors = FALSE)
SEA_country <- dictionary("Vietnam", 0, df_country)

# South East Asia ISO ----------------------------------------------------------
df_iso <- df_all
names(df_iso) <- c("country", "translate", "var_1", "var_2", "var_3")
df_iso["var4"] <- df_iso$translate
df_iso2 <- data.frame(
  "translate" = c("KH-22", "LA-VT", "TH-14"),
  "var_1" = c("Kep", "Vientiane_prefecture", "Phra Nakhon Si Ayutthaya"),
  stringsAsFactors = FALSE)
df_iso2[setdiff(names(df_iso), names(df_iso2))] <- NA
df_iso <- rbind(df_iso, df_iso2)
ISO_admin1 <- dictionary(add_dict = df_iso)

df_isoc <- df_country
names(df_isoc) <- c("translate", "var_1", "var_2", "var_3")
df_isoc["var4"] <- df_isoc$translate
ISO_country <- dictionary(add_dict = df_isoc)

# Writing to disk --------------------------------------------------------------

usethis::use_data(kh_admin1, la_admin1, th_admin1,
                   vn_admin1, vn_admin2, la_admin2,
                   SEA_country, ISO_country, ISO_admin1,
                   overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
