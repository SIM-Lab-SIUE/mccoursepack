# Internal helper
.has_exec <- function(cmd, args = "--version") {
  path <- Sys.which(cmd)
  if (!nzchar(path)) return(FALSE)
  ok <- tryCatch({
    out <- system2(path, args, stdout = TRUE, stderr = TRUE)
    length(out) > 0
  }, error = function(e) FALSE)
  ok
}

#' Check that R meets a minimum version
#' @keywords internal
check_r_min <- function(min_version = "4.3.0") {
  ok <- getRversion() >= as.package_version(min_version)
  if (ok) cli::cli_alert_success("R {as.character(getRversion())} OK (>= {min_version}).")
  else    cli::cli_alert_danger("R {as.character(getRversion())} < {min_version}.")
  ok
}

#' Check RStudio availability
#' @keywords internal
check_rstudio <- function() {
  ok <- rlang::is_installed("rstudioapi") && rstudioapi::isAvailable()
  if (ok) cli::cli_alert_success("RStudio detected.")
  else    cli::cli_alert_warning("RStudio not detected (OK if using another editor).")
  ok
}

#' Check Quarto CLI
#' @keywords internal
check_quarto <- function() {
  ok <- .has_exec("quarto", "--version")
  if (ok) cli::cli_alert_success("Quarto found.")
  else    cli::cli_alert_danger("Quarto not found. Install from https://quarto.org/docs/get-started/")
  ok
}

#' Check Git CLI
#' @keywords internal
check_git <- function() {
  ok <- .has_exec("git", "--version")
  if (ok) cli::cli_alert_success("Git found.")
  else    cli::cli_alert_danger("Git not found. Install from https://git-scm.com/downloads")
  ok
}

#' Validate a course/week bundle is installed in the package
#' @keywords internal
check_course_tree <- function(course = "mc451", week = 1) {
  src <- system.file("courses", course, "weeks", sprintf("week_%02d", week), package = "mccoursepack")
  ok <- src != ""
  if (ok) cli::cli_alert_success("Course/week found in package: {course} week {week}.")
  else    cli::cli_alert_danger("Course/week not found in package: {course} week {week}.")
  ok
}

#' Quick environment self-test
#' @export
mccourse_self_test <- function(course = "mc451", week = 1) {
  ver <- as.character(utils::packageVersion("mccoursepack"))
  cli::cli_inform("mccoursepack version: {ver}")
  tibble::tibble(
    r        = check_r_min("4.3.0"),
    rstudio  = check_rstudio(),
    quarto   = check_quarto(),
    git      = check_git(),
    course   = check_course_tree(course, week)
  )
}