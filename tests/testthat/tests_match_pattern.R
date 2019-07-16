library(magrittr) # for " %>% "
library(dplyr)    # for "tibble", "mutate"
library(tidyr)    # for "unnest"

context("`match_pattern`")

test_that("`match_pattern` returns the correct output", {

  df <- tibble(vn_admin1_year) %>%
    mutate(year = names(vn_admin1_year)) %>%
    tidyr::unnest() %>%
    rename(admin1 = "vn_admin1_year")

  expect_identical(match_pattern(df %>% filter(year == "1979-1990"),
                                 "admin1", vn_admin1_year),
                   "1979-1990")

  expect_identical(match_pattern(df %>% filter(year == "1990-1991"),
                                 "admin1", vn_admin1_year),
                   "1990-1991")

  expect_identical(match_pattern(df %>% filter(year == "1979-1990") %>% head,
                                 "admin1", vn_admin1_year, strict = FALSE),
                   "1979-1990")

  expect_null(match_pattern(df %>% filter(year == "1979-1990") %>% head,
                            "admin1", vn_admin1_year))
})
