#' Download a week's template into a destination directory
#'
#' Copies the installed files for a given `course` and `week` into `dest`.
#' If the week template is empty (e.g., holiday weeks), this succeeds quietly
#' and copies nothing.
#'
#' Backward compatibility: if you call `download_week(1, dest)`, it assumes there
#' is a single course installed and uses it. If multiple courses exist, you must
#' supply the `course` argument.
#'
#' @param course Course name (e.g., "mc451", "mc501"). If omitted and `week` is
#'   provided as the first argument, the function will try to infer a single installed
#'   course; if multiple courses exist, it errors with a clear message.
#' @param week Integer or string like "01".
#' @param dest Destination directory (created if needed). Defaults to current dir.
#' @return (invisibly) a list with `dest`, `course`, `week`, and `n_copied`.
#' @examples
#' \donttest{
#' # Preferred explicit form:
#' download_week("mc451", 1, dest = ".")
#'
#' # Back-compat (only if a single course is installed):
#' download_week(1, dest = ".")
#' }
#' @export
download_week <- function(course, week = NULL, dest = ".") {
  # Back-compat: allow download_week(week, dest)
  if (is.null(week)) {
    if (missing(course)) stop("Provide either (course, week) or at least 'week'.", call. = FALSE)
    # If first arg is numeric-like, treat as week
    if (length(course) == 1 && (is.numeric(course) || grepl("^\\d+$", course))) {
      week <- course
      crs <- list_courses()
      if (!length(crs)) stop("No installed courses found.", call. = FALSE)
      if (length(crs) > 1) {
        stop("Multiple courses installed (", paste(crs, collapse = ", "),
             "). Please call download_week(course, week, ...).", call. = FALSE)
      }
      course <- crs[[1L]]
    } else {
      stop("Usage: download_week(course, week, dest = '.')", call. = FALSE)
    }
  }
  
  week <- sprintf("%02d", as.integer(week))
  src <- .mcp_src_for_course_week(course, week)
  if (!nzchar(src) || !dir.exists(src)) {
    stop("Template for course '", course, "' week ", week, " not found in the installed package.", call. = FALSE)
  }
  
  if (!dir.exists(dest)) {
    dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  }
  
  # files within src (exclude directories)
  src_files <- list.files(
    src, recursive = TRUE, all.files = TRUE,
    full.names = TRUE, no.. = TRUE
  )
  src_files <- src_files[!dir.exists(src_files)]
  
  if (length(src_files) == 0L) {
    return(invisible(list(dest = normalizePath(dest), course = course, week = week, n_copied = 0L)))
  }
  
  # relative paths
  esc <- function(x) gsub("([\\^\\$\\\\.\\|\\(\\)\\[\\]\\*\\+\\?])", "\\\\\\1", x)
  rel <- sub(paste0("^", esc(normalizePath(src)), "/?"), "", normalizePath(src_files))
  
  # ensure subdirs
  subdirs <- unique(dirname(rel))
  for (d in subdirs) {
    if (nzchar(d)) {
      dir.create(file.path(dest, d), recursive = TRUE, showWarnings = FALSE)
    }
  }
  
  ok <- file.copy(
    from = src_files,
    to   = file.path(dest, rel),
    overwrite = TRUE,
    copy.mode = TRUE,
    copy.date = TRUE
  )
  n_copied <- sum(ok)
  
  invisible(list(dest = normalizePath(dest), course = course, week = week, n_copied = n_copied))
}