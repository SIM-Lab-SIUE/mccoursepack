test_that("download_week copies files when present and no-ops for empty weeks", {
  root <- system.file("templates", package = "mccoursepack")
  skip_if(identical(root, ""), "No templates installed with the package")

  weeks <- dir(root, pattern = "^week\\d+$", full.names = TRUE)
  skip_if(!length(weeks), "No week directories found under inst/templates")

  for (wpath in weeks) {
    wk_label <- sub("^week", "", basename(wpath))
    td <- withr::local_tempdir()

    expect_no_error(download_week(wk_label, dest = td), info = paste("week", wk_label))

    # Source files (ignore directories)
    src_files <- list.files(wpath, recursive = TRUE, all.files = TRUE,
                            full.names = TRUE, no.. = TRUE)
    src_files <- src_files[!dir.exists(src_files)]

    # Dest files (ignore directories)
    dest_files <- list.files(td, recursive = TRUE, all.files = TRUE,
                             full.names = TRUE, no.. = TRUE)
    dest_files <- dest_files[!dir.exists(dest_files)]

    if (length(src_files) == 0L) {
      # Empty template week (e.g., Thanksgiving): should copy nothing but still succeed
      expect_equal(length(dest_files), 0L,
                   info = paste("empty template should yield empty copy for week", wk_label))
    } else {
      # Non-empty template week: at least one file should be copied
      if (!length(dest_files)) {
        cat("\nDEBUG (", wk_label, ") dest empty; src listing:\n", sep = "")
        print(list.files(wpath, recursive = TRUE))
      }
      expect_gt(length(dest_files), 0L,
                info = paste("files should be copied for week", wk_label))
    }
  }
})