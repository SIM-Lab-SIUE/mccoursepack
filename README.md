# mc-coursepack (repo)
Minimal R package to distribute weekly course content for MC451 (undergrad) and MC501 (grad).

## Install (from source)
```r
# in the package root:
# install.packages("devtools") if needed
devtools::install_local(upgrade = "never")
```

## Use
```r
library(mccoursepack)
list_weeks("mc451")
download_week("mc451", 1)  # writes ./week_01 with minimal QMD scaffold
```
