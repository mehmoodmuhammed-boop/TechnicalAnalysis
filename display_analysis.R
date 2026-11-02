# BDA400 Assignment 2 - Technical Analysis using R
# Student: Mehmood Muhammad
# File: display_analysis.R
#
# Run from the Assignment2 directory after running setup_packages.R.
# This script imports stock_functions.R, downloads data, prints results,
# saves CSV outputs and creates a price/average visualization for each stock.

required <- c("quantmod", "TTR", "ggplot2", "dplyr")
missing <- required[!vapply(required, requireNamespace, quietly = TRUE,
                            FUN.VALUE = logical(1))]
if (length(missing) > 0) {
  stop("Missing packages: ", paste(missing, collapse = ", "),
       ". Run setup_packages.R first.")
}

source("stock_functions.R")

output_dir <- "output"
plot_dir <- file.path(output_dir, "plots")
dir.create(plot_dir, recursive = TRUE, showWarnings = FALSE)

# Download the most recent 12 months of data.
stock_data <- load_stock_data(
  portfolio_file = "portfolio.txt",
  from = Sys.Date() - 365,
  to = Sys.Date()
)

# Display the first rows for each symbol and save each data frame.
for (symbol in names(stock_data)) {
  cat("\n----------------------------------------\n")
  cat("Stock:", symbol, "\n")
  print(utils::head(stock_data[[symbol]], 10))
  utils::write.csv(
    stock_data[[symbol]],
    file = file.path(output_dir, paste0(symbol, "_data.csv")),
    row.names = FALSE
  )
}

# Calculate and display required statistics for all imported symbols.
statistics <- calculate_portfolio_statistics(
  stock_data,
  moving_average_window = 20
)
cat("\nPortfolio statistics:\n")
print(statistics)
utils::write.csv(statistics,
                 file = file.path(output_dir, "portfolio_statistics.csv"),
                 row.names = FALSE)

# Create a closing-price chart with a 20-day simple moving average.
for (symbol in names(stock_data)) {
  df <- stock_data[[symbol]]
  df$Adjusted <- as.numeric(df$Adjusted)
  df$SMA20 <- as.numeric(TTR::SMA(df$Adjusted, n = 20))

  chart <- ggplot2::ggplot(df, ggplot2::aes(x = Date)) +
    ggplot2::geom_line(ggplot2::aes(y = Adjusted, colour = "Adjusted close"),
                       linewidth = 0.6, na.rm = TRUE) +
    ggplot2::geom_line(ggplot2::aes(y = SMA20, colour = "20-day SMA"),
                       linewidth = 0.8, na.rm = TRUE) +
    ggplot2::labs(
      title = paste(symbol, "- Adjusted Closing Price and 20-Day SMA"),
      x = "Date",
      y = "Price (USD)",
      colour = "Series",
      caption = "Source: Yahoo Finance via quantmod; educational use."
    ) +
    ggplot2::theme_minimal()

  print(chart)
  ggplot2::ggsave(
    filename = file.path(plot_dir, paste0(symbol, "_price_sma.png")),
    plot = chart,
    width = 9,
    height = 5,
    dpi = 150
  )
}

cat("\nAnalysis complete. CSV files and plots are saved in:", output_dir, "\n")
