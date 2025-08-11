# mccoursepack

Course materials for **MC 451 (Undergraduate)** and **MC 501 (Graduate)** delivered as an R package. Install or update the package each week, then use its helper functions to pull your week’s scaffold (Quarto docs, instructions, and any starter files) into your local folders. ([GitHub][1])

---

## What you’ll do with this package

* Install/update the package.
* List available weeks for your course.
* Download the scaffold for a specific week into a folder on your computer.
* Open the Quarto (`.qmd`) files, complete the work, render to HTML/PDF as needed, and submit by pushing to GitHub.

> Some weeks are intentionally empty (e.g., holidays). Downloading those weeks will succeed but copy no files—that’s normal.

---

## Prerequisites (one‑time)

1. **Accounts & software**

* A GitHub account (use your SIUE email).
* R (current version) and RStudio Desktop.
* Quarto (needed to render `.qmd` files): [https://quarto.org/docs/get-started/](https://quarto.org/docs/get-started/)
* Git (so RStudio can push/pull):

  * Windows: install Git for Windows.
  * macOS: install Xcode Command Line Tools (`xcode-select --install`) or Git.

2. **R packages you’ll need at some point**

* `pak` or `remotes` (to install this course package from GitHub).
* `tidyverse` (typical data wrangling/plotting).
* `withr`, `testthat` (used internally; you may not need to load them yourself).

3. **Optional for PDF output**

* TinyTeX: run `quarto install tinytex` in the RStudio Terminal if you need to render to PDF and don’t already have LaTeX.

---

## Install (first time)

Pick **one** method.

**Using pak (recommended):**

```r
install.packages("pak")
pak::pak("SIM-Lab-SIUE/mccoursepack")
```

**Using remotes:**

```r
install.packages("remotes")
remotes::install_github("SIM-Lab-SIUE/mccoursepack", upgrade = "never")
```

Verify:

```r
library(mccoursepack)
packageVersion("mccoursepack")
```

---

## Update (every week)

Each Monday, update to get the latest materials:

**pak:**

```r
pak::pak("SIM-Lab-SIUE/mccoursepack")
```

**remotes:**

```r
remotes::install_github("SIM-Lab-SIUE/mccoursepack", upgrade = "always", force = TRUE)
```

---

## Recommended folder setup (local)

Create a top‑level folder per course on your computer, for example:

```
~/Documents/MC451/
~/Documents/MC501/
```

Inside those, each week you’ll have a `week_01`, `week_02`, … folder. Your journals and assignments live inside the week’s folder and are pushed to GitHub.

---

## First‑week course “preflight” (one‑time)

1. **GitHub Profile README (intro assignment)**

   * On GitHub, create a **public** repository named **exactly** your username (e.g., `apleith`).
   * Add a `README.md` with a short intro.
   * Upload a profile picture on your GitHub profile page.

2. **Journal repository**

   * Create a **new repository** named `mc451-journal` (or `mc501-journal`).
   * Clone it to your computer via RStudio (**File → New Project → Version Control → Git**).
   * You’ll add a journal `.qmd` or `.md` each week and push it to this repo.

(Your course site/Blackboard will specify exact submission links and any naming conventions.)

---

## Core workflow each week

> The package exposes helper functions to list available weeks and download that week’s scaffold to your machine. The current repo README shows examples like `list_weeks("mc451")` followed by `download_week("mc451", 1)`. ([GitHub][1])

1. **Open RStudio** and set your working directory to your course folder (e.g., `~/Documents/MC451`).

2. **List available weeks (by course):**

```r
library(mccoursepack)
list_weeks("mc451")   # or list_weeks("mc501")
```

3. **Download a week’s scaffold:**

```r
# Example: download Week 1 of MC 451 into a new local folder
download_week("mc451", 1, dest = ".")
# Typically creates ./week_01 with a Quarto scaffold and any starter files
```

* If the week is a holiday (empty template), the call will succeed but no files will be created. That’s expected.

4. **Open the week in RStudio**

   * File pane → navigate to `week_01` (or your week) → open the `.qmd` file(s).
   * Read the top instructions in the file. They describe the specific tasks.

5. **Write and render**

   * Add your responses (e.g., 250–300 words for a journal) and any required code/plots.
   * Render to HTML: click **Render** in the RStudio editor (or run `quarto render` in the Terminal).

6. **Commit & push to GitHub**

   * **Git** pane → **Stage** changed files → **Commit** with a clear message → **Push**.
   * Submit the GitHub link per the course instructions.

---

## Journal workflow details

* Keep one journal repository all term (`mc451-journal` or `mc501-journal`).
* Each week, either:

  * Add a new file `journal_week_01.qmd`, `journal_week_02.qmd`, etc., **or**
  * Append to a single cumulative `journal.qmd` with weekly sections.
* Render to HTML and commit both the source (`.qmd`) and the rendered output (HTML or PDF as required).
* Push the repo and share the link as instructed.

---

## Assignment workflow details

* The weekly scaffold typically includes an assignment `.qmd` with instructions and a checklist.
* Complete the checklist at the bottom of the file (where present) explaining how you met each requirement.
* Render, commit, and push before the deadline.

---

## Verifying you’re on the correct week/version

* Check the package version:

  ```r
  packageVersion("mccoursepack")
  ```
* Re‑run:

  ```r
  list_weeks("mc451")
  ```

  to confirm the week you need is present.
* If a week isn’t listed yet, update the package (see **Update**).

---

## Common tasks & examples

* **Download a later week to a named folder:**

  ```r
  dir.create("Week05")     # optional custom folder name
  download_week("mc451", 5, dest = "Week05")
  ```
* **Re-download (overwrite) an existing week scaffold:**

  * Delete or rename the existing folder, then re-run `download_week(...)`.

---

## Troubleshooting

**“Quarto not found”**

* Install Quarto from the official site and restart RStudio. If on Windows, ensure the installer added Quarto to PATH.

**Render won’t produce PDF**

* Use HTML unless the assignment requires PDF.
* If PDF is required, run `quarto install tinytex` in the Terminal and re-render.

**I don’t see my week in `list_weeks()`**

* Update the package, restart R, and try again:

  ```r
  pak::pak("SIM-Lab-SIUE/mccoursepack")
  # or
  remotes::install_github("SIM-Lab-SIUE/mccoursepack", upgrade = "always", force = TRUE)
  ```

**`download_week()` runs but no files appear**

* You might have downloaded a holiday/empty week (normal).
* Confirm your working directory (top of the Console: `getwd()`).
* Check that you passed the correct course label (`"mc451"` or `"mc501"`) and a valid week number.

**Git push fails**

* Configure Git user/email in RStudio: **Tools → Global Options → Git/SVN**.
* Ensure you’ve authenticated GitHub in RStudio (via the **Git** pane or **Tools → Global Options → Git/SVN → Create New Token**).
* Try again after restarting RStudio.

**Windows path issues**

* Keep your course folder path short (e.g., `C:/Users/you/Documents/MC451`) to avoid the Windows path length limit.

**I rendered but GitHub only shows the `.qmd`**

* Commit and push the rendered HTML (`.html`) as well.
* If using GitHub Pages, make sure your repo is configured for Pages (only if instructed).

---

## Where this package puts things

* Course templates live inside the installed package and are copied out when you call `download_week(...)`.
* You work in your local folders (e.g., `~/Documents/MC451/week_03/`), not inside the package library.

---

## Getting help

* Re‑read the week’s `.qmd` instructions at the top.
* Check this README for setup and update steps.
* If you’re stuck, open a question on the course discussion space (or follow your instructor’s posted support process). Include:

  * Your OS (Windows/macOS), R and RStudio versions
  * The **exact** code you ran
  * The **full** error message
  * A screenshot of your folder structure (if relevant)

---

## Quick reference

```r
# Install or update
install.packages("pak"); pak::pak("SIM-Lab-SIUE/mccoursepack")

# Load
library(mccoursepack)

# See what weeks exist for your course
list_weeks("mc451")    # or list_weeks("mc501")

# Pull a specific week into the current folder
download_week("mc451", 1, dest = ".")

# Check your version
packageVersion("mccoursepack")
```

---

## Notes for the curious

The repository’s minimal README shows the same basic usage:

```r
library(mccoursepack)
list_weeks("mc451")
download_week("mc451", 1)  # writes ./week_01 with minimal QMD scaffold
```

This README expands those steps with student‑facing setup, workflows, and troubleshooting. ([GitHub][1])

---

**License:** MIT

**Repository:** SIM-Lab-SIUE/mccoursepack ([GitHub][1])

---

[1]: https://github.com/SIM-Lab-SIUE/mccoursepack "GitHub - SIM-Lab-SIUE/mccoursepack: This is the coursework material for MC 451 + 501."
