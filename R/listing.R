#' List available courses that have week templates installed
#'
#' Looks under the installed package path 'inst/courses/<course>/weeks/week_XX'.
#'
#' @return A character vector of course names (e.g., "mc451", "mc501").
#' @examples
#' list_courses()
#' @export
list_courses <- function() {
  base <- .mcp_courses_root()
  if (identical(base, "")) return(character(0))
  dirs <- dir(base, full.names = FALSE, recursive = FALSE)
  # keep those that contain a 'weeks' dir with at least one 'week_XX'
  keep <- vapply(dirs, function(d) {
    wr <- file.path(base, d, "weeks")
    dir.exists(wr) && length(dir(wr, pattern = "^week_\\d+$", full.names = FALSE)) > 0
  }, logical(1))
  sort(dirs[keep])
}

#' List available week templates
#'
#' If `course` is supplied, returns the weeks (e.g., "01", "02", ...) for that course.
#' If `course` is `NULL`, it aggregates weeks **across all installed courses** and
#' returns the sorted unique set. This ensures `list_weeks()` runs safely in examples.
#'
#' @param course Optional course directory name (e.g., "mc451", "mc501").
#' @return A character vector of available week numbers, without the "week_" prefix.
#' @examples
#' # Aggregate weeks across all installed courses (safe for examples):
#' list_weeks()
#' # Weeks for a specific course (if installed):
#' \donttest{
#' list_weeks("mc451")
#' }
#' @export
list_weeks <- function(course = NULL) {
  if (is.null(course)) {
    crs <- list_courses()
    if (!length(crs)) return(character(0))
    uniq <- unique(unlist(lapply(crs, .mcp_weeks_for_course), use.names = FALSE))
    return(sort(uniq))
  }
  .mcp_weeks_for_course(course)
}