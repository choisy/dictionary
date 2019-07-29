context("`match_pattern`")

test_that("`match_pattern` returns the correct output", {

  df  <- data.frame(unlist(vn_admin1_year))
  df[, "year"] <- row.names(df)
  colnames(df) <- c("admin1", "year")
  df$year <- substr(df$year, 1, 9)

  expect_identical(match_pattern(df[which(df$year == "1979-1990"), ],
                                 "admin1", vn_admin1_year),
                   "1979-1990")

  expect_identical(match_pattern(df[which(df$year == "1990-1991"), ],
                                 "admin1", vn_admin1_year),
                   "1990-1991")

  expect_identical(match_pattern(df[which(df$year == "1979-1990"), ],
                                 "admin1", vn_admin1_year, strict = FALSE),
                   "1979-1990")

  expect_null(match_pattern(head(df[which(df$year == "1979-1990"), ]),
                            "admin1", vn_admin1_year))
})
