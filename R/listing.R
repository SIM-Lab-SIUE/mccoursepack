#' List available courses in the package
#' @export
list_courses <- function() {
  root <- system.file("courses", package = "mccoursepack")
  if (root == "") return(character())
  fs::dir_ls(root, type = "directory") |> fs::path_file() |> sort()
}

#' List available weeks for a course
#' @param course e.g., "mc451"
#' @export
list_weeks <- function(course) {
  base <- system.file("courses", course, "weeks", package = "mccoursepack")
  if (base == "") cli::cli_abort("Unknown course: {course}")
  fs::dir_ls(base, type = "directory") |> fs::path_file() |> sort()
}

#' Open a downloaded week in your editor
#' @export
open_week <- function(course, week, dest = NULL) {
  if (is.null(dest)) {
    root <- tryCatch({ if (rlang::is_installed("here")) here::here() else getwd() }, error = function(e) getwd())
    dest <- fs::path(root, "coursework", course, sprintf("week_%02d", week))
  }
  if (!fs::dir_exists(dest)) cli::cli_abort("{.path {dest}} not found. Did you run download_week()?")
  target <- fs::path(dest, "README.md")
  if (fs::file_exists(target) && rlang::is_installed("rstudioapi") && rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(target, line = 1)
  }
  invisible(dest)
}