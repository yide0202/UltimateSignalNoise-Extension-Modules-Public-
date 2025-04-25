# DesignFileParser.R

# Dependencies
if (!requireNamespace("jsonlite", quietly = TRUE)) stop("The 'jsonlite' package is required")
if (!requireNamespace("ape", quietly = TRUE))       stop("The 'ape' package is required")
library(jsonlite)
library(ape)

#' Parse a JSON design file into analysis parameters
#'
#' This will read keys:
#'   - freqs           : numeric vector (length 4 or 20)
#'   - subratevector   : numeric vector
#'   - ratevector      : numeric vector (optional)
#'   - guideTree       : Newick string or filepath
#'   - empiricalTree   : Newick string or filepath
#'   - alnFile         : character
#'   - internode       : numeric (scalar)
#'
#' and return an R list ready for `TreeCollapse.signal.noise()`.
#'
#' @param jsonFile Character. Path to the input JSON design file.
#' @return Named list with elements: freqs, subratevector, guideTree,
#'         empiricalTree, alnFile, internode, ratevector.
#' @export
parse_design_file <- function(jsonFile) {
  if (!file.exists(jsonFile)) stop("Design JSON file not found: ", jsonFile)
  data <- jsonlite::fromJSON(jsonFile)
  required <- c("freqs","subratevector","guideTree","empiricalTree","alnFile","internode")
  miss <- setdiff(required, names(data))
  if (length(miss) > 0) stop("Missing fields: ", paste(miss, collapse = ", "))
  freqs         <- as.numeric(data$freqs)
  subratevector <- as.numeric(data$subratevector)
  alnFile       <- as.character(data$alnFile)
  internode     <- as.numeric(data$internode)
  
  parse_tree <- function(x) {
    if (file.exists(x)) {
      read.tree(x)
    } else {
      read.tree(text = x)
    }
  }
  guideTree     <- parse_tree(data$guideTree)
  empiricalTree <- parse_tree(data$empiricalTree)
  
  ratevector <- if (!is.null(data$ratevector)) as.numeric(data$ratevector) else NULL
  
  list(
    freqs         = freqs,
    subratevector = subratevector,
    guideTree     = guideTree,
    empiricalTree = empiricalTree,
    alnFile       = alnFile,
    internode     = internode,
    ratevector    = ratevector
  )
}
