# BDA400 Assignment 2 — Technical Analysis using R
**Student:** Mehmood Muhammad  
**Course:** BDA400 — Data Science Tools and Techniques

## Folder contents
- `portfolio.txt` — stock symbols, one per line.
- `setup_packages.R` — installs and loads the required R packages.
- `stock_functions.R` — portfolio reader, stock downloader and statistics functions.
- `display_analysis.R` — imports data, prints records, exports CSV files and creates charts.
- `Assignment2_Report.docx` — assignment report and evidence checklist.
- `screenshots/` — add your own screenshots of the completed setup and execution steps.
- `output/` — generated automatically when `display_analysis.R` runs.

## Run the project
1. Install R and RStudio.
2. Open this `Assignment2` folder as the RStudio working directory (or set it with `setwd()`).
3. Run `setup_packages.R`.
4. Run `display_analysis.R`.
5. Review the console, `output/` CSV files and `output/plots/` charts.

## Portfolio
The supplied example portfolio contains AAPL, MSFT and NVDA. These are editable examples, not a claim about the student's personal investments. Replace them with the symbols you intend to analyze, one symbol per line.

## GitHub
Create a GitHub repository named `TechnicalAnalysis`, then upload this `Assignment2` folder. The repository URL must be added to the report cover page after the repository is actually created.

## Important
Stock data is retrieved from Yahoo Finance through `quantmod`; an internet connection is required. Historical data may change or become unavailable. The scripts report download failures. Run the scripts yourself and capture genuine screenshots before submitting.
