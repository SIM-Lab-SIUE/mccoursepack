.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    needs <- FALSE
    if (!.mcp_have_quarto())  needs <- TRUE
    if (!.mcp_have_tinytex()) needs <- TRUE
    core <- c("tidyverse","janitor","here","knitr","rmarkdown")
    if (any(!core %in% rownames(installed.packages()))) needs <- TRUE

    if (needs) {
      packageStartupMessage(
        "mccoursepack: run `mccourse_setup()` once to install Quarto, TinyTeX, and core packages."
      )
    }
  }
}
