#' Download a week's template into a destination directory
#'
#' Copies the installed files for a given week into `dest`. If the week template
#' is empty (e.g., holiday weeks), this succeeds quietly and copies nothing.
#'
#' @param week Integer or string like "01".
#' @param dest Destination directory (created if needed).
#' @return (invisibly) a small struct with dest, week, and n_copied.
#' @export
download_week <- function(week, dest = ".") {
  week <- sprintf("%02d", as.integer(week))
  src <- system.file("templates", paste0("week", week), package = "mccoursepack")
  if (identical(src, "")) {
    stop("Template for week ", week, " not found in the installed package.", call. = FALSE)
  }

  if (!dir.exists(dest)) {
    dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  }

  # All files under src (exclude directories)
  src_files <- list.files(
    src, recursive = TRUE, all.files = TRUE,
    full.names = TRUE, no.. = TRUE
  )
  src_files <- src_files[!dir.exists(src_files)]

  # If no files, succeed quietly
  if (length(src_files) == 0L) {
    return(invisible(structure(
      list(dest = normalizePath(dest), week = week, n_copied = 0L),
      class = "download_week_result"
    )))
  }

  # Build relative paths against src
  # Escape src for regex in sub()
  esc <- function(x) gsub("([\\^\\$\\\\.\\|\\(\\)\\[\\]\\*\\+\\?])", "\\\\\\1", x)
  rel <- sub(paste0("^", esc(src), "/?"), "", src_files)

  # Create any needed subdirectories in dest
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

  invisible(structure(
    list(dest = normalizePath(dest), week = week, n_copied = n_copied),
    class = "download_week_result"
  ))
}