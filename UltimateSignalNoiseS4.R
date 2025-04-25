# UltimateSignalNoiseS4.R

# Dependencies
if (!requireNamespace("ape", quietly = TRUE))       stop("The 'ape' package is required")
if (!requireNamespace("phylobase", quietly = TRUE)) stop("The 'phylobase' package is required")
library(ape)
library(phylobase)

# Allow NULL for ratevector
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
  prototype = list(ratevector = NULL),
  validity = function(obj) {
    if (length(obj@freqs) == 0)
      return("`freqs` must be non-empty")
    if (length(obj@subratevector) == 0)
      return("`subratevector` must be non-empty")
    if (length(obj@internode) != 1)
      return("`internode` must be a single numeric value")
    TRUE
  }
)

# Coercion to ape::phylo (extract gene tree)
setAs("UltimateSignalNoiseData", "phylo", function(from) {
  from@empiricalTree
})

# Coercion to phylobase::phylo4
setAs("UltimateSignalNoiseData", "phylo4", function(from) {
  as(as(from, "phylo"), "phylo4")
})

#' Show method prints a brief summary
setMethod("show", "UltimateSignalNoiseData", function(object) {
  cat("UltimateSignalNoiseData object\n")
  cat("  # freqs:", length(object@freqs), "\n")
  cat("  # subratevector:", length(object@subratevector), "\n")
  cat("  # ratevector:", if (is.null(object@ratevector)) "NULL" else length(object@ratevector), "\n")
  cat("  alnFile:", object@alnFile, "\n")
  cat("  internode:", object@internode, "\n")
  cat("  guideTree tips:", length(object@guideTree$tip.label), "\n")
  cat("  empiricalTree tips:", length(object@empiricalTree$tip.label), "\n")
})

