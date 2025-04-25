# UltimateSignalNoise-Extension-Modules-Public-

This repository supplements the original `UltimateSignalNoise.R` framework (Townsend et al. 2012) with three independent helper modules that add:

1. **IQ-TREE integration** for on-the-fly estimation of site-specific rates  
2. **JSON design-file support** for declarative experiment specification  
3. **S4 data‐container** for clean parameter management and `phylo` ↔ `phylo4` conversion  

> **Important**: None of the original functions, signatures, or internal logic in `UltimateSignalNoise.R` are modified. These helpers simply wrap and prepare inputs so you can call  
> ```r
> TreeCollapse.signal.noise(…)
> ```
> exactly as before.

---

## 📚 Background & Design Rationale

Phylogenetic experimental design weighs **signal** (correct synapomorphies) against **noise** (homoplasies) to predict the power of a dataset to resolve a particular internode in a tree. Townsend *et al.* (2012) derived a quartet-based framework (an *s*-state Poisson model) to compute:

- **Signal**: P(site changes in the target internode & is not obscured)  
- **Noise**: P(homoplastic changes that mimic an incorrect bipartition)  
- **Polytomy**: P(no parsimony-informative pattern)

### Key References

- Townsend, J. P., Su, Z., & Tekle, Y. I. (2012). *Phylogenetic Signal and Noise: Predicting the Power of a Data Set to Resolve Phylogeny*. **Syst. Biol.**, 61(5):835–849.  
- Su, Z. & Townsend, J. P. (2015). *Impact of Quartet Internode & Subtending Branch Lengths on Phylogenetic Noise and Signal*.  
- Su, Z., López-Giráldez, F., & Townsend, J. P. (2014). *Incorporating Molecular Substitution Models into Predictions of Phylogenetic Signal and Noise*. **Front. Ecol. Evol.**, 2:11.  
- Dornburg, A., Su, Z., & Townsend, J. P. (2018). *Optimal Rates for Phylogenetic Inference and Experimental Design*. **Syst. Biol.**, 68(1):145–156.  
- López-Giráldez, F., Moeller, A. H., & Townsend, J. P. (2013). *Evaluating Phylogenetic Informativeness as a Predictor of Signal*. **BioMed Res. Int.**, 2013:621604.

---

## 🧩 Module Summaries

### 1. IQTreeIntegration.R

```r
#' run_iqtree_site_rates(alnFile, iqbinary="iqtree2", model="GTR+G", ...)
#'
#' - Runs IQ-TREE with `-wsr` to compute per-site rates.
#' - Requires `iqtree2` (or your installed binary) in PATH.
#' - Returns a numeric vector of length = #sites.
```
### Usage: 
```r
library(IQTreeIntegration)
rates <- run_iqtree_site_rates("my_alignment.phy",
                              iqbinary="iqtree2",
                              model="GTR+G")
```
### 2. DesignFileParser.R

```r
#' parse_design_file(jsonFile)
#'
#' Reads a JSON with keys:
#'   freqs           : numeric[4]  
#'   subratevector   : numeric  
#'   guideTree       : Newick string or filepath  
#'   empiricalTree   : Newick string or filepath  
#'   alnFile         : character  
#'   internode       : numeric  
#'   ratevector      : numeric (optional)
#'
#' Returns a list suitable for passing to TreeCollapse.signal.noise().
```
### Usage:
```r
library(DesignFileParser)
params <- parse_design_file("experiment.json")
```
### 3. UltimateSignalNoiseS4.R
```r
#' UltimateSignalNoiseData S4 class
#' Slots:
#'   freqs         : numeric (length = 4 or 20)
#'   subratevector : numeric
#'   ratevector    : numeric or NULL
#'   guideTree     : phylo
#'   empiricalTree : phylo
#'   alnFile       : character
#'   internode     : numeric (scalar)
#'
#' Coercions:
#'   as(x, "phylo")  → phylo(guideTree)
#'   as(x, "phylo4") → phylo4(guideTree)
```
### Usage:
```r
library(UltimateSignalNoiseS4)
obj <- new("UltimateSignalNoiseData",
           freqs         = c(0.25,0.25,0.25,0.25),
           subratevector = c(1.0,1.2,0.8,...),
           ratevector    = NULL,
           guideTree     = ape::read.tree("species.nwk"),
           empiricalTree = ape::read.tree("gene.nwk"),
           alnFile       = "alignment.phy",
           internode     = 7)
```
## 🚀 Putting It All Together
### Create a JSON (experiment.json):
```r
{
  "freqs": [0.25, 0.25, 0.25, 0.25],
  "subratevector": [1.0, 1.2, 0.8, …],
  "guideTree": "((A,B),(C,D));",
  "empiricalTree": "gene_tree.nwk",
  "alnFile": "my_alignment.phy",
  "internode": 7
}
```
### Main R script:
```r
# Load all helper modules
source("IQTreeIntegration.R")
source("DesignFileParser.R")
source("UltimateSignalNoiseS4.R")

# Load the original (unchanged) core functions
source("UltimateSignalNoise.R")

# 1) Parse JSON → list
params <- parse_design_file("experiment.json")

# 2) Compute rates via IQ-TREE if needed
if (is.null(params$ratevector)) {
  params$ratevector <- run_iqtree_site_rates(params$alnFile)
}

# 3) Package into S4 container
obj <- new("UltimateSignalNoiseData",
           freqs         = params$freqs,
           subratevector = params$subratevector,
           ratevector    = params$ratevector,
           guideTree     = params$guideTree,
           empiricalTree = params$empiricalTree,
           alnFile       = params$alnFile,
           internode     = params$internode)

# 4) Call the original analysis
result <- TreeCollapse.signal.noise(data = obj)

print(result)
```

# References

- Townsend, J. P., Su, Z., & Tekle, Y. I. (2012). Phylogenetic Signal and Noise: Predicting the Power of a Data Set to Resolve Phylogeny. *Systematic Biology*, 61(5), 835–849.

- Su, Z., López-Giráldez, F., & Townsend, J. P. (2014). The impact of incorporating molecular evolutionary model into predictions of phylogenetic signal and noise. *Frontiers in Ecology and Evolution*, 2, 11.

- Dornburg, A., Su, Z., & Townsend, J. P. (2018). Optimal Rates for Phylogenetic Inference and Experimental Design. *Systematic Biology*, 68(1), 145–156.

- López-Giráldez, F., Moeller, A. H., & Townsend, J. P. (2013). Evaluating Phylogenetic Informativeness as a Predictor of Signal. *BioMed Research International*, 2013, 621604.

