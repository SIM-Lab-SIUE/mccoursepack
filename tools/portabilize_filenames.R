# tools/portabilize_filenames.R
make_portable <- function(path) {
  # convert "Week 02 - MC 451 Reading Journal.qmd" -> "reading_journal.qmd"
  # conservatively: if it already endswith .qmd and contains 'Reading Journal'
  files <- list.files(path, pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
  for (f in files) {
    base <- basename(f)
    dirn <- dirname(f)
    
    # Proposed new name
    if (grepl("Reading Journal\\.qmd$", base, ignore.case = TRUE)) {
      new <- "reading_journal.qmd"
    } else {
      # generic fallback: lower, spaces->_, collapse dups
      new <- tolower(gsub("[^A-Za-z0-9._-]+", "_", base))
      new <- gsub("_+", "_", new)
    }
    
    target <- file.path(dirn, new)
    if (!identical(f, target)) {
      if (file.exists(target)) {
        message("Skipping rename to existing file: ", target)
      } else {
        message("Renaming: ", f, " -> ", target)
        file.rename(f, target)
      }
    }
  }
}

make_portable("inst/courses")