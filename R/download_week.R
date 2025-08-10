#' Download a week's materials into a local folder
#'
#' Copies the packaged files for a given course/week into a local directory.
#'
#' @param course "mc451" or "mc501"
#' @param week Integer week number (1+)
#' @param dest Destination directory. Defaults to coursework/<course>/week_## under the current project (if any), otherwise getwd().
#' @param overwrite "ask" (default), TRUE, or FALSE
#' @return (invisibly) a tibble listing file paths and copy status
#' @export
download_week <- function(course, week, dest = NULL, overwrite = c("ask","TRUE","FALSE")) {
  overwrite <- match.arg(as.character(overwrite), c("ask","TRUE","FALSE"))
  stopifnot(is.character(course), length(course) == 1, grepl("^mc(451|501)$", course))
  stopifnot(is.numeric(week), length(week) == 1, week >= 1)
  
  src <- system.file("courses", course, "weeks", sprintf("week_%02d", week), package = "mccoursepack")
  if (src == "") cli::cli_abort("Week {week} for course {course} is not installed in the package.")
  
  # Default destination
  if (is.null(dest)) {
    root <- tryCatch({
      if (rlang::is_installed("here")) here::here() else getwd()
    }, error = function(e) getwd())
    dest <- fs::path(root, "coursework", course, sprintf("week_%02d", week))
  }
  
  fs::dir_create(dest)
  files <- fs::dir_ls(src, recurse = FALSE, type = "file")
  
  copy_one <- function(f) {
    tgt <- fs::path(dest, fs::path_file(f))
    if (fs::file_exists(tgt)) {
      if (identical(overwrite, "FALSE")) {
        return(tibble::tibble(file = tgt, copied = FALSE, reason = "exists"))
      }
      if (identical(overwrite, "ask")) {
        if (interactive()) {
          ans <- utils::menu(c("Overwrite", "Skip"),
                             title = sprintf("File exists: %s", fs::path_file(tgt)))
          if (ans != 1) return(tibble::tibble(file = tgt, copied = FALSE, reason = "skipped"))
        } else {
          # Non-interactive: default to skip
          return(tibble::tibble(file = tgt, copied = FALSE, reason = "skipped-noninteractive"))
        }
      }
    }
    fs::file_copy(f, tgt, overwrite = TRUE)
    tibble::tibble(file = tgt, copied = TRUE, reason = "copied")
  }
  
  out <- purrr::map_dfr(files, copy_one)
  
  # Create helpful folders if present in source tree
  for (sub in c("data","img")) {
    sdir <- fs::path(src, sub)
    if (fs::dir_exists(sdir)) {
      ddir <- fs::path(dest, sub)
      fs::dir_create(ddir)
      sfiles <- fs::dir_ls(sdir, recurse = TRUE, type = "file")
      if (length(sfiles)) {
        fs::dir_create(unique(fs::path(ddir, fs::path_dir(fs::path_rel(sfiles, sdir)))))
        fs::file_copy(sfiles, fs::path(ddir, fs::path_rel(sfiles, sdir)), overwrite = TRUE)
        out <- dplyr::bind_rows(out, tibble::tibble(
          file = fs::path(ddir, fs::path_rel(sfiles, sdir)),
          copied = TRUE,
          reason = "copied"
        ))
      }
    }
  }
  
  cli::cli_inform(c(
    "v" = "Downloaded {sum(out$copied)} file{?s} to {.path {dest}}",
    if (any(!out$copied)) "!" = "{sum(!out$copied)} file{?s} skipped"
  ))
  invisible(out)
}