library(dictionary)

# INFORMATION ------------------------------------------------------------------

# We use the name of the admin1 given by GADM without accent or special
# character as translation.
# Source : gadm: https://gadm.org
# To complete our dictionary with different variation of name, we also include
# the data for admin1 and admin2 by country coming from the geonames website:
# Source: http://download.geonames.org/export/dump/

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

# Dictionary of the names of the communes in Vietnam ---------------------------

communes <- read.table("data-raw/vietnam/communes.txt", sep = ";",
                       header = TRUE, stringsAsFactors = FALSE)
communes$old <- stringi::stri_escape_unicode(communes$old)
admin3 <- with(communes, setNames(new, old))

# History ----------------------------------------------------------------------

vn_history <- make_history("data-raw/History_txtfile/vn_history.txt",
                           dictionary::vn_admin1)

th_history <- make_history("data-raw/History_txtfile/th_history.txt",
                           dictionary::th_admin1)

la_history <- make_history("data-raw/History_txtfile/la_history.txt",
                           dictionary::la_admin1,
                           dictionary::la_admin2)

kh_history <- make_history("data-raw/History_txtfile/kh_history.txt",
                           dictionary::kh_admin1)

# Admin1_year list -------------------------------------------------------------

la_admin1_year <- list_year_admin1("Laos", la_admin1, la_history,
                                   from = "1997")
kh_admin1_year <- list_year_admin1("Cambodia", kh_admin1, kh_history,
                                   from = "1994")
th_admin1_year <- list_year_admin1("Thailand", th_admin1, th_history,
                                   from = "1967")
vn_admin1_year <- list_year_admin1("Vietnam", vn_admin1, vn_history,
                                   from = "1979")

# Writing to disk --------------------------------------------------------------

usethis::use_data(kh_admin1, la_admin1, th_admin1,
                  vn_admin1, vn_admin2, la_admin2,
                  SEA_country, ISO_country, ISO_admin1,
                  admin3,
                  vn_history, th_history, la_history, kh_history,
                  la_admin1_year, kh_admin1_year, th_admin1_year,
                  vn_admin1_year, overwrite = TRUE)

# Remove everything ------------------------------------------------------------

rm(list = ls())
