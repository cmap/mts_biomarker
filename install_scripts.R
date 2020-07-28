#
install.packages("devtools")
install.packages("BiocManager") # to install rhdf5

BiocManager::install("limma", ask = FALSE)
devtools::install_github("cmap/cmapR", dependencies=TRUE, force=TRUE)
devtools::install_github("broadinstitute/taigr", dependencies=TRUE, force=TRUE)
devtools::install_github("broadinstitute/cdsr_biomarker", dependencies=TRUE, force=TRUE)

