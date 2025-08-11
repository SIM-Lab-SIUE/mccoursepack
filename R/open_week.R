#' Open a downloaded week's folder in your system file browser
#'
#' Convenience helper: after you've used `download_week()` to create a local
#' folder (e.g., `./week_01`), this opens that folder in your default file browser.
#'
#' @param week Integer or string like "01".
#' @param dest Parent directory where the week folder resides. Defaults to `.`.
#' @return Invisibly, the opened path.
#' @examples
#' \donttest{
#' download_week("mc451", 1, ".")
#' open_week(1, ".")
#' }
#' @export
open_week <- function(week, dest = ".") {
  week <- sprintf("%02d", as.integer(week))
  candidates <- file.path(dest, paste0("week_", week))
  if (!dir.exists(candidates)) candidates <- dest
  utils::browseURL(normalizePath(candidates))
  invisible(candidates)
}