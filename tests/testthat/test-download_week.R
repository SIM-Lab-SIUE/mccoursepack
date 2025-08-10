test_that("download_week copies files", {
  skip_on_cran()
  td <- withr::local_tempdir()
  out <- mccoursepack::download_week("mc451", 1, dest = td, overwrite = TRUE)
  expect_true(nrow(out) > 0)
  expect_true(any(file.exists(file.path(td, "README.md"))))
})
