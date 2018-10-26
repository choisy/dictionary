library(magrittr) # for " %>% "
library(dplyr)    # for "tibble", "mutate"
library(tidyr)    # for "unnest"

context("`match_pattern`")

test_that("`match_pattern` returns the correct output", {

  df <- tibble(vn_province_year) %>%
    mutate(year = names(vn_province_year)) %>%
    tidyr::unnest() %>%
    rename(province = "vn_province_year")

  expect_identical(match_pattern(df %>% filter(year == "1979-1990"),
                                 "province", vn_province_year),
                   "1979-1990")

  expect_identical(match_pattern(df %>% filter(year == "1990-1991"),
                                 "province", vn_province_year),
                   "1990-1991")

  expect_identical(match_pattern(df %>% filter(year == "1979-1990") %>% head,
                                 "province", vn_province_year, strict = FALSE),
                   "1979-1990")

  expect_null(match_pattern(df %>% filter(year == "1979-1990") %>% head,
                            "province", vn_province_year))
})
