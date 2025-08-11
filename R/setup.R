#' One-time setup for MC course tools
#'
#' Checks for Quarto, TinyTeX (for PDF), and installs core R packages if missing.
#' Designed to be safe on lab machines: asks before any big install unless
#' `ask = FALSE`.
#'
#' @param ask If TRUE (default), prompts before installing Quarto/TinyTeX.
#' @param pkgs Character vector of CRAN packages to ensure are installed.
#' @return Invisibly TRUE when done.
#' @examples
#' \dontrun{
#' mccourse_setup()  # run once
#' }
#' @export
mccourse_setup <- function(
  ask  = TRUE,
  pkgs = c(
    "tidyverse","janitor","here",
    "readr","dplyr","ggplot2","stringr","lubridate",
    "knitr","rmarkdown"
  )
) {
  # 1) Ensure CRAN packages
  missing <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(missing)) utils::install.packages(missing)

  # 2) Ensure Quarto CLI
  have_quarto <- .mcp_have_quarto()
  if (!have_quarto) {
    if (ask && interactive()) {
      message("Quarto not found. It is required to render PDF/HTML.")
      resp <- readline("Install Quarto now? [Y/n]: ")
      if (nzchar(resp) && tolower(substr(resp, 1, 1)) == "n") return(invisible(FALSE))
    }
    .mcp_install_quarto()
  }

  # 3) Ensure TinyTeX (LaTeX) for PDF
  have_tinytex <- .mcp_have_tinytex()
  if (!have_tinytex) {
    if (ask && interactive()) {
      message("TinyTeX (LaTeX) not found. It is required for PDF rendering.")
      resp <- readline("Install TinyTeX now? (This is ~200–300MB) [Y/n]: ")
      if (nzchar(resp) && tolower(substr(resp, 1, 1)) == "n") return(invisible(FALSE))
    }
    .mcp_install_tinytex()
  }

  invisible(TRUE)
}

# --- internal helpers (no :: to avoid check warnings) ---

.mcp_have_quarto <- function() {
  if (!requireNamespace("quarto", quietly = TRUE)) return(FALSE)
  qp <- get("quarto_path", asNamespace("quarto"))
  p  <- tryCatch(qp(), error = function(e) "")
  is.character(p) && nzchar(p)
}

.mcp_install_quarto <- function() {
  if (!requireNamespace("quarto", quietly = TRUE)) utils::install.packages("quarto")
  qi <- get("quarto_install", asNamespace("quarto"))
  tryCatch(qi(), error = function(e) stop("Failed to install Quarto: ", e$message, call. = FALSE))
}

.mcp_have_tinytex <- function() {
  if (!requireNamespace("tinytex", quietly = TRUE)) return(FALSE)
  is_tt <- get("is_tinytex", asNamespace("tinytex"))
  isTRUE(is_tt())
}

.mcp_install_tinytex <- function() {
  if (!requireNamespace("tinytex", quietly = TRUE)) utils::install.packages("tinytex")
  it <- get("install_tinytex", asNamespace("tinytex"))
  tryCatch(it(), error = function(e) stop("Failed to install TinyTeX: ", e$message, call. = FALSE))
}
