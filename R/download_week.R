#' Download a week's template into a destination directory
#'
#' Copies the installed files for a given `course` and `week` into a
#' subfolder named `week_XX` inside `dest`. If the week template is empty
#' (e.g., holiday weeks), it still creates the `week_XX` folder and copies nothing.
#'
#' Backward compatibility: if you call `download_week(1, dest)`, it assumes there
#' is a single installed course and uses it. If multiple courses exist, you must
#' supply the `course` argument.
#'
#' @param course Course name (e.g., "mc451", "mc501"). For back-compat you may
#'   pass only `week` as the first argument if exactly one course is installed.
#' @param week Integer or string like `"01"` or `"week_01"`.
#' @param dest Destination directory (created if needed). Defaults to current dir.
#' @return (invisibly) a list with `dest` (the created week folder), `course`,
#'   `week`, and `n_copied`.
#' @examples
#' \dontrun{
#' # Use a temporary folder in examples/checks (portable on Windows)
#' d <- tempdir()
#' download_week("mc451", 1, dest = d)  # creates d/week_01/...
#' }
#' @export
download_week <- function(course, week = NULL, dest = ".") {
  # Back-compat: allow download_week(week, dest) if only one course installed
  if (is.null(week)) {
    if (missing(course)) stop("Provide either (course, week) or at least 'week'.", call. = FALSE)
    if (length(course) == 1 && (is.numeric(course) || grepl("^\\d+$", course) || grepl("^week_\\d+$", course))) {
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

  # Accept "01" or "week_01"
  if (is.character(week) && grepl("^week_\\d+$", week)) {
    week_num <- sub("^week_", "", week)
  } else {
    week_num <- sprintf("%02d", as.integer(week))
  }

  src <- .mcp_src_for_course_week(course, week_num)
  if (!nzchar(src) || !dir.exists(src)) {
    stop("Template for course '", course, "' week ", week_num, " not found in the installed package.", call. = FALSE)
  }

  # Ensure destination and *week subfolder* exist
  if (!dir.exists(dest)) dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  target_dir <- file.path(dest, paste0("week_", week_num))
  if (!dir.exists(target_dir)) dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)

  # List files to copy (exclude directories)
  src_files <- list.files(src, recursive = TRUE, all.files = TRUE, full.names = TRUE, no.. = TRUE)
  src_files <- src_files[!dir.exists(src_files)]

  # Empty week: return after ensuring the folder exists
  if (length(src_files) == 0L) {
    return(invisible(list(dest = normalizePath(target_dir),
                          course = course, week = week_num, n_copied = 0L)))
  }

  # Normalize to forward slashes so sub() works on Windows too
  src_norm    <- normalizePath(src,       winslash = "/", mustWork = TRUE)
  files_norm  <- normalizePath(src_files, winslash = "/", mustWork = TRUE)

  # Relative paths from src -> used under target_dir
  rel <- sub(paste0("^", gsub("([\\^\\$\\\\.\\|\\(\\)\\[\\]\\*\\+\\?])", "\\\\\\1", src_norm), "/?"),
             "", files_norm)

  # Ensure subdirs under the target dir
  subdirs <- unique(dirname(rel))
  for (d in subdirs) {
    if (!identical(d, ".") && nzchar(d)) {
      dir.create(file.path(target_dir, d), recursive = TRUE, showWarnings = FALSE)
    }
  }

  ok <- file.copy(from = src_files, to = file.path(target_dir, rel),
                  overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
  n_copied <- sum(ok)

  invisible(list(dest = normalizePath(target_dir),
                 course = course, week = week_num, n_copied = n_copied))
}

# internal helper (unchanged)
.mcp_src_for_course_week <- function(course, week_num) {
  root <- .mcp_course_weeks_root(course)
  if (!nzchar(root)) return("")
  file.path(root, paste0("week_", week_num))
}
