context("`translate`")

test_that("Test `translate` returns the correct output", {

  vect <- translate(c("AnGiang", "HaNoi"), country = "Vietnam", level = 1)
  testthat::expect_equal(unique(vect),  c("An Giang", "Ha Noi"))

  vect <- translate(c("AnGiang", "HaNoi"), vn_province)
  testthat::expect_equal(unique(vect),  c("An Giang", "Ha Noi"))

  testthat::expect_error(translate(c("AnGiang", "HaNoi"), country = "Vietnam"))
  testthat::expect_error(
    translate(c("AnGiang", "HaNoi"), country = "France", level = 1))
})
