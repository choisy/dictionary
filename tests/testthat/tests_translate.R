context("`translate`")

test_that("Test `translate` returns the correct output", {

  vect <- translate(c("AnGiang", "HaNoi"), "Vietnam", 1)
  testthat::expect_equal(unique(vect),  c("An Giang", "Ha Noi"))

})
