context("`dictionary`")

test_that("`dictionary` returns correct output", {
  df1 <- data.frame(name = "Kandal,Phnom Penh",
                    asciiname = "Kandal", stringsAsFactors = FALSE)
  df2 <- data.frame(name = "Phra Nakhon Si Ayutthaya,Bangkok",
                    asciiname = "Phra Nakhon Si Ayutthaya", stringsAsFactors = FALSE)
  test1 <- dictionary:::alternate_name(df1, "asciiname", ",")
  test2 <- dictionary:::alternate_name(df2, "asciiname", ",")
  expect_identical(any(grepl("Phnom Penh", test1)), FALSE)
  expect_identical(any(grepl("Bangkok", test2)), FALSE)

  expect_error(dictionary("france", 30))

  expect_error(dictionary("france", 0, 1))

  expect_error(dictionary("france", 0, data.frame(col = 1)))

  expect_error(dictionary("france", 0, data.frame(var = 1, col = 1)))

  test3 <- dictionary("france", 0, data.frame(var = 1, translate = 1))
  expect_identical(test3, c("1" = 1, France = "France", france = "France", FRANCE = "France"))
})
