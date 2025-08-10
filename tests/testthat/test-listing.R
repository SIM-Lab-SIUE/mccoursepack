test_that("list_weeks finds week_01 for mc451", {
  expect_true("week_01" %in% mccoursepack::list_weeks("mc451"))
})
