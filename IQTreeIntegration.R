# IQTreeIntegration.R

# Dependencies
if (!requireNamespace("ape", quietly = TRUE)) stop("The 'ape' package is required")
library(ape)

#' Run IQ-TREE to compute site-specific rates
#'
#' This function checks for the IQ-TREE executable, runs it on the given alignment file
#' with the `-wsr` (write site rates) option, and reads the resulting `.rate` file into an R numeric vector.
#'
#' @param alnFile  Character. Path to the input alignment file.
#' @param iqbinary Character. Name or full path to the IQ-TREE executable (default `"iqtree2"`).
#' @param model    Character. Substitution model to use (default `"GTR+G"`).
#' @param ...      Additional arguments passed to IQ-TREE.
#' @return         Numeric vector of site rates from the `.rate` file.
#' @seealso       get_iqtree_ratefile_path
#' @export
run_iqtree_site_rates <- function(alnFile, iqbinary = "iqtree2", model = "GTR+G", ...) {
  if (!file.exists(alnFile)) stop("Alignment file not found: ", alnFile)
  iq_path <- Sys.which(iqbinary)
  if (iq_path == "" || is.na(iq_path)) stop("IQ-TREE executable '", iqbinary, "' not found in PATH.")
  args <- c("-s", shQuote(alnFile), "-m", model, "-wsr", ...)
  message("Running IQ-TREE: ", iqbinary, " ", paste(args, collapse = " "))
  res <- system2(iqbinary, args = args, stdout = TRUE, stderr = TRUE)
  rate_file <- get_iqtree_ratefile_path(alnFile)
  if (!file.exists(rate_file)) stop("Expected .rate file not found: ", rate_file)
  ratevector <- scan(rate_file, what = numeric(), quiet = TRUE)
  if (length(ratevector) == 0) stop("Rate file is empty: ", rate_file)
  ratevector
}

#' Derive the expected IQ-TREE site-rate filename
#'
#' IQ-TREE will append `.rate` to your alignment prefix.  If you
#' passed `file.phy`, the rates go to `file.phy.rate`.  This helper
#' computes that path reliably.
#'
#' @param alnFile Character. Path to the alignment.
#' @return Character path to the `.rate` file.
#' @export
get_iqtree_ratefile_path <- function(alnFile) {
  paste0(alnFile, ".rate")
}
