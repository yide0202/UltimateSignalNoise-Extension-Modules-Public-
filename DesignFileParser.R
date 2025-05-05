# -------------------------------
# File: DesignFileParser.R
# -------------------------------
# NOTE: New JSON design-file parser module. Original code relied on manual R parameter calls without declarative JSON input support.
# -------------------------------

# Dependencies
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("The 'jsonlite' package is required for JSON parsing")
}
if (!requireNamespace("ape", quietly = TRUE)) {
  stop("The 'ape' package is required for tree parsing")
}
library(jsonlite)
library(ape)

#' Parse a JSON design file into analysis parameters
#'
#' Reads keys:
#'   - freqs           : numeric vector (length 4 or 20)
#'   - subratevector   : numeric vector
#'   - ratevector      : numeric vector (optional)
#'   - guideTree       : Newick string or filepath
#'   - empiricalTree   : Newick string or filepath
#'   - alnFile         : character
#'   - internode       : numeric (scalar)
#'
#' @param jsonFile Character. Path to the input JSON design file.
#' @return Named list with elements: freqs, subratevector, guideTree,
#'         empiricalTree, alnFile, internode, ratevector.
#' @export
#'
#' Implementation updates:
#' - Validates required fields (`freqs`, `subratevector`, `guideTree`, `empiricalTree`, `alnFile`, `internode`).
#' - Supports both Newick string and file path for tree inputs via `parse_tree()` helper.
#' - Handles optional `ratevector`, defaulting to `NULL` if not provided.
parse_design_file <- function(jsonFile) {
  if (!file.exists(jsonFile)) {
    stop("Design JSON file not found: ", jsonFile)
  }
  data <- jsonlite::fromJSON(jsonFile)
  required <- c("freqs", "subratevector", "guideTree", "empiricalTree", "alnFile", "internode")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop("Missing fields in JSON: ", paste(missing, collapse = ", "))
  }
  # Coerce and validate
  freqs         <- as.numeric(data$freqs)
  subratevector <- as.numeric(data$subratevector)
  alnFile       <- as.character(data$alnFile)
  internode     <- as.numeric(data$internode)
  # Helper for trees: file or text
  parse_tree <- function(x) {
    if (file.exists(x)) {
      read.tree(x)
    } else {
      read.tree(text = x)
    }
  }
  guideTree     <- parse_tree(data$guideTree)
  empiricalTree <- parse_tree(data$empiricalTree)
  # Optional ratevector
  ratevector <- if (!is.null(data$ratevector)) as.numeric(data$ratevector) else NULL

  return(list(
    freqs         = freqs,
    subratevector = subratevector,
    ratevector    = ratevector,
    guideTree     = guideTree,
    empiricalTree = empiricalTree,
    alnFile       = alnFile,
    internode     = internode
  ))
}

