# Internal helpers for course + week paths. Not exported.

.mcp_courses_root <- function() {
  # installed location of 'inst/courses'
  system.file("courses", package = "mccoursepack")
}

.mcp_course_weeks_root <- function(course) {
  base <- .mcp_courses_root()
  if (identical(base, "")) return("")
  file.path(base, course, "weeks")
}

.mcp_weeks_for_course <- function(course) {
  root <- .mcp_course_weeks_root(course)
  if (!nzchar(root) || !dir.exists(root)) return(character(0))
  wk_dirs <- dir(root, pattern = "^week_\\d+$", full.names = FALSE)
  # Return "01", "02", ...
  sub("^week_", "", wk_dirs)
}

.mcp_src_for_course_week <- function(course, week) {
  week <- sprintf("%02d", as.integer(week))
  root <- .mcp_course_weeks_root(course)
  if (!nzchar(root)) return("")
  file.path(root, paste0("week_", week))
}