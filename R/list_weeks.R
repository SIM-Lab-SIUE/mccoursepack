#' List available courses (if present) or week templates
#'
#' If your package organizes templates by course (e.g., `inst/templates/mc451/week01`),
#' this returns the list of course directories (e.g., `mc451`, `mc501`). If not,
#' it returns an empty character vector.
#'
#' @return A character vector of course directory names found under `inst/templates`.
#' @examples
#' list_courses()
#' @export
list_courses <- function() {
  root <- system.file("templates", package = "mccoursepack")
  if (identical(root, "")) return(character(0))
  dirs <- dir(root, full.names = FALSE, recursive = FALSE)
  # Only directories that contain at least one weekXX subdir
  courses <- character(0)
  for (d in dirs) {
    cand <- file.path(root, d)
    if (dir.exists(cand)) {
      wk <- dir(cand, pattern = "^week\\d+$", full.names = FALSE)
      if (length(wk)) courses <- c(courses, d)
    }
  }
  unique(courses)
}

#' List available week templates
#'
#' Lists installed week directories of the form `week01`, `week02`, … If you pass
#' a course name that exists under `inst/templates/<course>/weekXX`, it lists the
#' weeks for that course. If `course` is `NULL` (default), it looks directly under
#' `inst/templates/`.
#'
#' @param course Optional course directory name (e.g., "mc451", "mc501").
#'   If `NULL`, weeks are listed from the top-level `inst/templates`.
#' @return A character vector of available weeks like `"01"`, `"02"`, … (no prefix).
#' @examples
#' list_weeks()
#' list_weeks("mc451")
#' @export
list_weeks <- function(course = NULL) {
  base <- system.file("templates", package = "mccoursepack")
  if (identical(base, "")) return(character(0))
  
  root <- if (is.null(course)) base else file.path(base, course)
  if (!dir.exists(root)) return(character(0))
  
  wk_dirs <- dir(root, pattern = "^week\\d+$", full.names = FALSE)
  if (!length(wk_dirs)) return(character(0))
  
  sub("^week", "", wk_dirs)
}