test_that("download_week copies files when present and no-ops for empty weeks", {
  base <- system.file("courses", package = "mccoursepack")
  skip_if(identical(base, ""), "No courses installed with the package")
  
  courses <- list_courses()
  skip_if(!length(courses), "No course directories found under inst/courses")
  
  for (course in courses) {
    weeks <- list_weeks(course)              # returns like "week_01"
    skip_if(!length(weeks), paste("No weeks found for", course))
    
    for (wk in weeks) {
      td <- withr::local_tempdir()
      expect_no_error(download_week(course, wk, dest = td))
      
      src <- file.path(base, course, "weeks", wk)
      src_files <- list.files(src, recursive = TRUE, all.files = TRUE, full.names = TRUE, no.. = TRUE)
      src_files <- src_files[!dir.exists(src_files)]
      
      dest_files <- list.files(td, recursive = TRUE, all.files = TRUE, full.names = TRUE, no.. = TRUE)
      dest_files <- dest_files[!dir.exists(dest_files)]
      
      if (length(src_files) == 0L) {
        expect_equal(length(dest_files), 0L)
      } else {
        if (!length(dest_files)) {
          cat("\nDEBUG:", course, wk, "dest empty; src listing:\n")
          print(list.files(src, recursive = TRUE))
        }
        expect_gt(length(dest_files), 0L)
      }
    }
  }
})