# -------------------------------
# File: UltimateSignalNoiseS4.R
# -------------------------------
# NOTE: New S4 class definition module. Original version did not include S4 object wrapper for parameters.
# -------------------------------

# Dependencies
if (!requireNamespace("ape", quietly = TRUE)) {
  stop("The 'ape' package is required for S4 tree handling")
}
if (!requireNamespace("phylobase", quietly = TRUE)) {
  stop("The 'phylobase' package is required for phylo4 objects")
}
library(ape)
library(phylobase)

# Define an S4 union for optional ratevector
setClassUnion("numericOrNULL", c("numeric", "NULL"))

#' S4 class for UltimateSignalNoise parameters
#'
#' Slots:
#'   freqs         : numeric (base freqs)
#'   subratevector : numeric
#'   ratevector    : numericOrNULL
#'   guideTree     : phylo
#'   empiricalTree : phylo
#'   alnFile       : character
#'   internode     : numeric (scalar)
#'
#' @exportClass UltimateSignalNoiseData
setClass(
  "UltimateSignalNoiseData",
  slots = list(
    freqs         = "numeric",
    subratevector = "numeric",
    ratevector    = "numericOrNULL",
    guideTree     = "phylo",
    empiricalTree = "phylo",
    alnFile       = "character",
    internode     = "numeric"
  ),
  prototype = list(
    freqs         = rep(0.25, 4),
    subratevector = rep(1, 6),
    ratevector    = NULL,
    guideTree     = read.tree(text="(A:1,B:1);"),
    empiricalTree = read.tree(text="(A:1,B:1);"),
    alnFile       = "",
    internode     = 1
  ),
  validity = function(object) {
    if (length(object@freqs) != 4) {
      return("`freqs` must have exactly 4 elements")
    }
    if (length(object@subratevector) != 6) {
      return("`subratevector` must have exactly 6 elements")
    }
    if (length(object@internode) != 1) {
      return("`internode` must be a single numeric value")
    }
    TRUE
  }
)

# NOTE: Added coercion methods so the S4 object can be converted directly to phylo and phylo4
# Coercions: extract empiricalTree as phylo, phylo4
setAs("UltimateSignalNoiseData", "phylo", function(from) {
  from@empiricalTree
})
setAs("UltimateSignalNoiseData", "phylo4", function(from) {
  as(as(from, "phylo"), "phylo4")
})

# Show method for convenience
setMethod(
  "show", "UltimateSignalNoiseData",
  function(object) {
    cat("UltimateSignalNoiseData object:\n")
    cat("  freqs:", object@freqs, "\n")
    cat("  subratevector:", object@subratevector, "\n")
    cat("  ratevector:", if (is.null(object@ratevector)) "NULL" else length(object@ratevector), "\n")
    cat("  alnFile:", object@alnFile, "\n")
    cat("  internode:", object@internode, "\n")
    cat("  guideTree tips:", length(object@guideTree$tip.label), "\n")
    cat("  empiricalTree tips:", length(object@empiricalTree$tip.label), "\n")
  }
)
