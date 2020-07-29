# packages required for biomarker id
install.packages("tidyverse")
install.packages("magrittr")
install.packages("gmodels")
install.packages("devtools")
install.packages("BiocManager") # to install limma

BiocManager::install("limma", ask = FALSE)
devtools::install_github("broadinstitute/taigr", dependencies=TRUE, force=TRUE)
devtools::install_github("broadinstitute/cdsr_models", dependencies=TRUE, force=TRUE)
