context("`make_history`")

test_that("`make_history` returns correct output", {
  test1 <- make_history("files_for_tests/la_history.txt", la_admin1, la_admin2)
  expect_type(test1, "list")
  expect_equal(length(test1), 2)
  expect_equal(unique(vapply(test1, length, 0)), 6)


})

