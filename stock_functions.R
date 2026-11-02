# BDA400 Assignment 2 - Technical Analysis using R
# Student: Mehmood Muhammad
# File: stock_functions.R
#
# Functions:
#   read_portfolio()       - reads symbols from portfolio.txt
#   load_stock_data()      - downloads OHLCV stock data using quantmod
#   calculate_statistics()- computes SMA, mean, mode, median and SD
#
# Note: Yahoo Finance availability, ticker validity and internet access can
# affect downloads. The function reports failed symbols instead of stopping
# the entire portfolio import.

read_portfolio <- function(file = "portfolio.txt") {
  if (!file.exists(file)) {
    stop("Portfolio file not found: ", file)
  }

  symbols <- readLines(file, warn = FALSE)
  symbols <- trimws(toupper(symbols))
  symbols <- symbols[nzchar(symbols)]
  symbols <- unique(symbols)

  if (length(symbols) == 0) {
    stop("portfolio.txt does not contain any stock symbols.")
  }

  symbols
}

load_stock_data <- function(portfolio_file = "portfolio.txt",
                            from = Sys.Date() - 365,
                            to = Sys.Date()) {
  if (!requireNamespace("quantmod", quietly = TRUE)) {
    stop("Package 'quantmod' is required. Run setup_packages.R first.")
  }

  symbols <- read_portfolio(portfolio_file)
  stock_data <- list()
  failures <- character(0)

  for (symbol in symbols) {
    message("Downloading: ", symbol)

    result <- tryCatch(
      quantmod::getSymbols(
        Symbols = symbol,
        src = "yahoo",
        from = from,
        to = to,
        auto.assign = FALSE,
        warnings = FALSE
      ),
      error = function(e) {
        failures <<- c(failures, paste0(symbol, ": ", conditionMessage(e)))
        NULL
      }
    )

    if (!is.null(result)) {
      df <- data.frame(
        Date = as.Date(zoo::index(result)),
        zoo::coredata(result),
        check.names = FALSE
      )
      names(df) <- sub(paste0("^", symbol, "\\."), "", names(df))
      stock_data[[symbol]] <- df
    }
  }

  if (length(failures) > 0) {
    warning(
      "Some symbols could not be downloaded:\n",
      paste(failures, collapse = "\n")
    )
  }

  if (length(stock_data) == 0) {
    stop("No stock data was downloaded. Check internet access and ticker symbols.")
  }

  attr(stock_data, "failed_symbols") <- failures
  stock_data
}

mode_value <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0) return(NA_real_)

  counts <- table(x)
  modes <- names(counts)[counts == max(counts)]

  # Return the smallest value if multiple modes have the same frequency.
  as.numeric(sort(as.numeric(modes))[1])
}

calculate_statistics <- function(stock_df, moving_average_window = 20) {
  if (!is.data.frame(stock_df)) {
    stop("stock_df must be a data frame.")
  }

  if (!"Adjusted" %in% names(stock_df)) {
    stop("The stock data must contain an Adjusted price column.")
  }

  adjusted <- as.numeric(stock_df$Adjusted)
  adjusted <- adjusted[is.finite(adjusted)]

  if (length(adjusted) == 0) {
    stop("No valid adjusted closing prices are available.")
  }

  moving_average <- if (length(adjusted) >= moving_average_window) {
    tail(TTR::SMA(adjusted, n = moving_average_window), 1)
  } else {
    NA_real_
  }

  data.frame(
    Moving_Average_Window = moving_average_window,
    Moving_Average = as.numeric(moving_average),
    Mean = mean(adjusted),
    Mode = mode_value(adjusted),
    Median = median(adjusted),
    Standard_Deviation = if (length(adjusted) > 1) stats::sd(adjusted) else NA_real_,
    Observations = length(adjusted),
    stringsAsFactors = FALSE
  )
}

calculate_portfolio_statistics <- function(stock_data,
                                           moving_average_window = 20) {
  if (length(stock_data) == 0) {
    stop("stock_data is empty.")
  }

  results <- lapply(stock_data, calculate_statistics,
                    moving_average_window = moving_average_window)
  combined <- do.call(rbind, results)
  combined$Symbol <- names(results)
  combined <- combined[, c("Symbol", setdiff(names(combined), "Symbol"))]
  rownames(combined) <- NULL
  combined
}
