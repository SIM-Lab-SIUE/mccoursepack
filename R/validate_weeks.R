# Internal: required files per week
.required_week_files <- function(week) {
  c(sprintf("chapter_%02d.qmd", week), "journal_template_general.qmd")
}

# Internal validator (called in CI)
.validate_week <- function(course, week) {
  root <- system.file("courses", course, "weeks", sprintf("week_%02d", week), package = "mccoursepack")
  if (root == "") cli::cli_abort("Week path not found in package: {course} week {week}.")
  req <- .required_week_files(week)
  missing <- req[!fs::file_exists(fs::path(root, req))]
  if (length(missing)) {
    cli::cli_abort(c(
      "Week {week} for {course} is missing required files:",
      stats::setNames(as.list(missing), rep("x", length(missing)))
    ))
  }
  TRUE
}
