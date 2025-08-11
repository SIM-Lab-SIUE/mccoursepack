#' Update mccoursepack to the latest version (CRAN or GitHub)
#'
#' This helper checks whether a newer version of \code{mccoursepack} is available
#' and, if so, can prompt to update (interactive) or return quietly (non-interactive).
#'
#' Configure the source with:
#' \itemize{
#'   \item \code{options(mccoursepack.repo = "owner/mccoursepack")} for GitHub
#'   \item or install from CRAN if the package is published there.
#' }
#'
#' To enable auto-checks before pulls:
#' \code{options(mccoursepack.auto_update = TRUE)} or set env var \code{MCCOURSEPACK_AUTO_UPDATE=1}.
#'
#' @param update "ask" (default), "always", or "never"
#' @param source "auto", "CRAN", or "GitHub"
#' @param repo GitHub "owner/repo" string if using GitHub (defaults to \code{getOption("mccoursepack.repo")})
#' @param quiet logical; reduce messages (useful when calling inside other helpers)
#' @return logical indicating whether an update was performed
#' @export
mccourse_update <- function(update = c("ask","always","never"),
                            source = c("auto","CRAN","GitHub"),
                            repo   = getOption("mccoursepack.repo", NULL),
                            quiet  = FALSE) {
  update <- match.arg(update)
  source <- match.arg(source)

  # Determine source
  if (identical(source, "auto")) {
    source <- if (!is.null(repo) && nzchar(repo)) "GitHub" else "CRAN"
  }

  # Check if update needed
  need <- .needs_update_mccoursepack(source = source, repo = repo, quiet = quiet)
  if (!isTRUE(need)) {
    if (!quiet) cli::cli_inform("mccoursepack is up to date ({as.character(utils::packageVersion('mccoursepack'))}).")
    return(FALSE)
  }

  # Decide behavior
  do_update <- switch(update,
    "always" = TRUE,
    "never"  = FALSE,
    "ask"    = if (interactive()) {
      ans <- utils::menu(c("Yes, update now", "No, not now"),
                         title = "A newer version of mccoursepack is available. Update?")
      ans == 1
    } else {
      if (!quiet) cli::cli_inform("Update available (non-interactive). Skipping. Set update='always' to auto-update.")
      FALSE
    }
  )

  if (!do_update) return(FALSE)

  ok <- .install_mccoursepack_latest(source = source, repo = repo, quiet = quiet)
  if (ok) {
    if (!quiet) cli::cli_alert_success("mccoursepack updated to {as.character(utils::packageVersion('mccoursepack'))}.")
    return(TRUE)
  } else {
    if (!quiet) cli::cli_alert_warning("Update attempt did not complete.")
    return(FALSE)
  }
}

# Internal: determine if newer version exists
.needs_update_mccoursepack <- function(source = c("CRAN","GitHub"), repo = NULL, quiet = FALSE) {
  source <- match.arg(source)
  installed <- tryCatch(utils::packageVersion("mccoursepack"), error = function(e) NA)
  if (is.na(installed)) return(TRUE) # not installed yet

  if (identical(source, "CRAN")) {
    # Light check using available.packages() if possible
    cran_ver <- tryCatch({
      ap <- utils::available.packages() # can be slow the first time, cached afterward
      if ("mccoursepack" %in% rownames(ap)) ap["mccoursepack","Version"] else NA_character_
    }, error = function(e) NA_character_)
    if (is.na(cran_ver)) return(FALSE)
    return(as.package_version(cran_ver) > installed)
  } else {
    # GitHub: require repo like "owner/mccoursepack"
    if (is.null(repo) || !nzchar(repo)) {
      if (!quiet) cli::cli_alert_warning("No GitHub repo configured. Set options(mccoursepack.repo = 'owner/mccoursepack').")
      return(FALSE)
    }
    if (!rlang::is_installed("remotes")) {
      if (!quiet) cli::cli_alert_warning("remotes not installed; cannot check GitHub updates.")
      return(FALSE)
    }
    deps <- tryCatch(remotes::package_deps(repo, upgrade = TRUE), error = function(e) NULL)
    if (is.null(deps)) return(FALSE)
    i <- which(deps$package == "mccoursepack")
    if (length(i) != 1) return(FALSE)
    diff <- deps$diff[i]
    # remotes marks updates when diff is not "=="
    isTRUE(nzchar(diff)) && !identical(diff, "==")
  }
}

# Internal: perform the install from CRAN or GitHub via pak or remotes
.install_mccoursepack_latest <- function(source = c("CRAN","GitHub"), repo = NULL, quiet = FALSE) {
  source <- match.arg(source)
  has_pak     <- rlang::is_installed("pak")
  has_remotes <- rlang::is_installed("remotes")

  if (identical(source, "CRAN")) {
    if (has_pak) {
      tryCatch({ pak::pkg_install("mccoursepack", upgrade = TRUE, ask = FALSE) ; TRUE },
               error = function(e) FALSE)
    } else if (has_remotes) {
      tryCatch({ remotes::install_cran("mccoursepack", upgrade = "always", quiet = quiet) ; TRUE },
               error = function(e) FALSE)
    } else {
      if (!quiet) cli::cli_alert_danger("Neither pak nor remotes is installed. Install one to enable updates.")
      FALSE
    }
  } else {
    if (is.null(repo) || !nzchar(repo)) {
      if (!quiet) cli::cli_alert_warning("No GitHub repo configured. Set options(mccoursepack.repo = 'owner/mccoursepack').")
      return(FALSE)
    }
    if (has_pak) {
      tryCatch({ pak::pkg_install(repo, upgrade = TRUE, ask = FALSE) ; TRUE },
               error = function(e) FALSE)
    } else if (has_remotes) {
      tryCatch({ remotes::install_github(repo, upgrade = "always", quiet = quiet) ; TRUE },
               error = function(e) FALSE)
    } else {
      if (!quiet) cli::cli_alert_danger("Neither pak nor remotes is installed. Install one to enable updates.")
      FALSE
    }
  }
}