# BDA400 Assignment 2 - Technical Analysis using R
# Student: Mehmood Muhammad
# File: setup_packages.R
# Run this script in RStudio before running the analysis scripts.

required_packages <- c("quantmod", "TTR", "ggplot2", "dplyr", "knitr", "rmarkdown")

install_if_missing <- function(packages) {
  missing_packages <- packages[
    !vapply(packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))
  ]

  if (length(missing_packages) > 0) {
    install.packages(missing_packages, repos = "https://cloud.r-project.org")
  }

  invisible(lapply(packages, function(pkg) {
    library(pkg, character.only = TRUE)
  }))
}

install_if_missing(required_packages)

cat("Package setup completed.\n")
sessionInfo()
