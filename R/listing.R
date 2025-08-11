#' List available courses that have week templates installed
#' @return A character vector of course names (e.g., "mc451", "mc501").
#' @examples
#' list_courses()
#' @export
list_courses <- function() {
  base <- .mcp_courses_root()
  if (identical(base, "")) return(character(0))
  dirs <- dir(base, full.names = FALSE, recursive = FALSE)
  keep <- vapply(dirs, function(d) {
    wr <- file.path(base, d, "weeks")
    dir.exists(wr) && length(dir(wr, pattern = "^week_\\d+$", full.names = FALSE)) > 0
  }, logical(1))
  sort(dirs[keep])
}

#' List available week templates
#'
#' If `course` is supplied, returns the **directory names** ("week_01", "week_02", ...).
#' If `course` is `NULL`, aggregates across courses and returns unique week dir names.
#'
#' @param course Optional course directory name (e.g., "mc451", "mc501").
#' @return A character vector like "week_01", "week_02", ...
#' @examples
#' # Aggregate across courses (safe in examples):
#' list_weeks()
#' # For a specific course (if installed):
#' \donttest{
#' list_weeks("mc451")
#' }
#' @export
list_weeks <- function(course = NULL) {
  base <- .mcp_courses_root()
  if (identical(base, "")) return(character(0))
  
  if (is.null(course)) {
    crs <- list_courses()
    if (!length(crs)) return(character(0))
    uniq <- unique(unlist(lapply(crs, function(c) {
      wr <- file.path(base, c, "weeks")
      dir(wr, pattern = "^week_\\d+$", full.names = FALSE)
    }), use.names = FALSE))
    return(sort(uniq))
  }
  
  wr <- .mcp_course_weeks_root(course)
  if (!nzchar(wr) || !dir.exists(wr)) return(character(0))
  sort(dir(wr, pattern = "^week_\\d+$", full.names = FALSE))
}