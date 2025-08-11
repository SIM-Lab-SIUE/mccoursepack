#' Minimal self-test for the installed course templates
#'
#' Checks that installed templates are discoverable and reports available weeks.
#' Returns `TRUE` invisibly on success.
#'
#' @return `TRUE` (invisibly) if templates are discoverable; otherwise, an error.
#' @examples
#' \donttest{
#' mccourse_self_test()
#' }
#' @export
mccourse_self_test <- function() {
  base <- .mcp_courses_root()
  if (identical(base, "")) {
    stop("No installed templates found under inst/courses in this package.", call. = FALSE)
  }
  crs <- list_courses()
  if (!length(crs)) {
    message("No courses found under installed 'courses/'.")
    return(invisible(TRUE))
  }
  message("Found courses: ", paste(crs, collapse = ", "))
  for (c in crs) {
    w <- list_weeks(c)
    message(sprintf("  - %s weeks: %s", c, if (length(w)) paste(w, collapse = ", ") else "<none>"))
  }
  invisible(TRUE)
}