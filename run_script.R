#---- PRE-SETUP (arguments and packages) ----
# Pass 3 arguments in this order:
# args[1] = full path to directory with data for a compound/project
# args[2] = full path to directory for output data
# args[3] = data version number for taiga
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop("Supply the required arguments as described", call.=FALSE)
}

# packages
suppressMessages(library(tidyverse))
suppressMessages(library(cdsrmodels))
suppressMessages(library(taigr))
suppressMessages(library(magrittr))

data_dir <- args[1]
output_dir <- args[2]
ver <- as.numeric(args[3])

# extract the project id from the input path and make the name safe so that it matches the MTS input folder name
pert_name <- basename(data_dir)
parent_dir <- dirname(data_dir)
project_name <- basename(parent_dir)
path_to_project <- dirname(parent_dir)
safe_name <- stringr::str_replace_all(project_name, "[[:punct:]\\s]+", "_")
safe_pert <- stringr::str_replace_all(pert_name, "[[:punct:]\\s]+", "-")
temp_out_dir <- dirname(output_dir)
temp_out_dir <- dirname(temp_out_dir)

#new data and output directories
data_dir <- paste(path_to_project, safe_name, safe_pert, sep = "/")
output_dir <- paste(temp_out_dir, safe_name, safe_pert, sep = "/")


#---- LOAD THE DATA ----
drc_path <- list.files(data_dir, pattern = "DRC_TABLE.csv", full.names = T)
lfc_path <- list.files(data_dir, pattern = "LFC_TABLE.csv", full.names = T)

# read dose-response if it's there
if (length(drc_path == 1)) {
  DRC <- data.table::fread(drc_path) %>%
    dplyr::distinct(ccle_name, culture, pert_time, pert_name, pert_mfc_id, auc, log2.ic50, max_dose) %>%
    dplyr::mutate(log2.ic50 = ifelse((is.finite(auc) & is.na(log2.ic50)),
                                     3 * max_dose, log2.ic50),
                  log2.auc = log2(auc)) %>%
    tidyr::pivot_longer(cols = c("log2.auc", "log2.ic50"),
                        names_to = "dose", values_to = "response") %>%
    dplyr::filter(is.finite(response))
} else {
  DRC <- tibble()
}

# always expect LFC table
LFC <- data.table::fread(lfc_path) %>%
  dplyr::distinct(pert_name, ccle_name, pert_time, culture, pert_idose, pert_mfc_id, LFC.cb) %>%
  dplyr::rename(response = LFC.cb, dose = pert_idose) %>%
  dplyr::filter(is.finite(response))

# combine into large table
all_Y <- dplyr::bind_rows(DRC, LFC)

# data names/types for loading from taiga
rf_data <- c("x-all", "x-ccle")
discrete_data <- c("lin", "mut")
linear_data <- c("ge", "xpr", "cna", "met", "mirna", "rep", "prot", "shrna")
linear_names <- c("GE", "XPR", "CNA", "MET", "miRNA", "REP", "PROT", "shRNA")
rep_meta <- load.from.taiga(data.name='primary-screen-e5c7', data.version=10,
                            data.file='primary-replicate-collapsed-treatment-info',
                            quiet = T) %>%
  dplyr::select(column_name, name) %>%
  dplyr::mutate(column_name = paste0("REP_", column_name))

# get lineage principal components to use as confounder
LIN_PCs <- taigr::load.from.taiga(data.name="mts013-b75e", data.version=ver,
                                  data.file="linPCA", quiet=T)

runs <- distinct(all_Y, pert_time, pert_name, pert_mfc_id, dose)

#---- LOOP THORUGH DATASETS AND DOSES ----

# linear associations
linear_table <- list(); ix <- 1
for(feat in 1:length(linear_data)) {

  # load feature set
  X <- taigr::load.from.taiga(data.name="mts013-b75e", data.version=ver,
                              data.file=linear_data[feat], quiet=T)

  # for each perturbation get results
  for(i in 1:nrow(runs)) {
    # filter down to current dose (run)
    run <- runs[i,]
    Y <- all_Y %>%
      dplyr::inner_join(run, by = c("pert_time", "pert_name", "pert_mfc_id", "dose"))
    y <- Y$response; names(y) <- Y$ccle_name
    y <- y[is.finite(y)]

    # get overlapping data
    overlap <- dplyr::intersect(rownames(X), names(y))
    y <- y[overlap]
    if (length(y) < 5 | min(y) == max(y)) next

    # calculate correlations
    res.lin <- cdsrmodels::lin_associations(X[overlap,], y)
    res.cor <- res.lin$res.table %>%
      cbind(., rho=res.lin$rho[rownames(.),], q.val=res.lin$q.val[rownames(.),]) %>%
      tibble::as_tibble() %>%
      dplyr::rename(feature = ind.var, coef = rho) %>%
      dplyr::arrange(q.val) %>%
      dplyr::mutate(rank = 1:n()) %>%
      dplyr::filter(rank <= 1000) %>%
      dplyr::mutate(pert_mfc_id = run$pert_mfc_id,
                    pert_name = run$pert_name,
                    pert_time = run$pert_time,
                    dose = run$dose,
                    feature_type = linear_names[feat])

    # for repurposing replace metadata
    if (linear_data[feat] == "rep") {
      res.cor %<>%
        dplyr::left_join(rep_meta, by = c("feature" = "column_name")) %>%
        dplyr::select(-feature) %>%
        dplyr::rename(feature = name) %>%
        dplyr::mutate(feature = paste("REP", feature, sep = "_"))
    }

    # append to output tables
    linear_table[[ix]] <- res.cor; ix <- ix + 1
  }

  # gene expression with lineage as confounder
  if (linear_data[feat] == "ge") {

    # for each perturbation get results
    for(i in 1:nrow(runs)) {
      # filter down to current dose (run)
      run <- runs[i,]
      Y <- all_Y %>%
        dplyr::inner_join(run, by = c("pert_time", "pert_name", "pert_mfc_id", "dose"))
      y <- Y$response; names(y) <- Y$ccle_name
      y <- y[is.finite(y)]

      # get overlapping data
      overlap <- dplyr::intersect(rownames(X), names(y)) %>%
        dplyr::intersect(., rownames(LIN_PCs))
      y <- y[overlap]
      if (length(y) < 5 | min(y) == max(y)) next

      # calculate correlations
      res.lin <- cdsrmodels::lin_associations(X[overlap,], y, W = LIN_PCs[overlap,])
      res.cor <- res.lin$res.table %>%
        cbind(., rho=res.lin$rho[rownames(.),], q.val=res.lin$q.val[rownames(.),]) %>%
        tibble::as_tibble() %>%
        dplyr::rename(feature = ind.var, coef = rho) %>%
        dplyr::arrange(q.val) %>%
        dplyr::mutate(rank = 1:n()) %>%
        dplyr::filter(rank <= 1000) %>%
        dplyr::mutate(pert_mfc_id = run$pert_mfc_id,
                      pert_name = run$pert_name,
                      pert_time = run$pert_time,
                      dose = run$dose,
                      feature_type = "GE_noLIN")
      linear_table[[ix]] <- res.cor; ix <- ix + 1
    }
  }
}
linear_table %<>% dplyr::bind_rows()

# repeat for discrete t-test
discrete_table <- list(); ix <- 1
for(feat in 1:length(discrete_data)) {
  X <- taigr::load.from.taiga(data.name="mts013-b75e", data.version=ver,
                              data.file=discrete_data[feat], quiet=T)
  for(i in 1:nrow(runs)) {
    run <- runs[i,]
    Y <- all_Y %>%
      dplyr::inner_join(run, by = c("pert_time", "pert_name", "pert_mfc_id", "dose"))
    y <- Y$response; names(y) <- Y$ccle_name
    y <- y[is.finite(y)]

    overlap <- dplyr::intersect(rownames(X), names(y))
    y <- y[overlap]

    if (length(y) < 5 | min(y) == max(y)) next

    res.disc <- cdsrmodels::discrete_test(X[overlap,], y)

    res.disc %<>%
      dplyr::mutate(pert_mfc_id = run$pert_mfc_id,
                    pert_name = run$pert_name,
                    pert_time = run$pert_time,
                    dose = run$dose,
                    feature_type = toupper(discrete_data[feat]))

    # only keep top 500 mutations
    if (discrete_data[feat] == "mut" & nrow(res.disc) > 0) {
      res.disc %<>%
        dplyr::arrange(q.value) %>%
        dplyr::mutate(rank = 1:n()) %>%
        dplyr::filter(rank <= 1000) %>%
        dplyr::select(-rank)
    }

    discrete_table[[ix]] <- res.disc; ix <- ix + 1
  }
}
discrete_table %<>% dplyr::bind_rows()

# repeat for random forest
random_forest_table <- list(); model_table <- list(); ix <- 1
for(feat in 1:length(rf_data)) {

  X <- taigr::load.from.taiga(data.name="mts013-b75e", data.version=ver,
                              data.file=rf_data[feat], quiet=T)
  model <- word(rf_data[feat], 2, sep = fixed("-"))

  for (i in 1:nrow(runs)) {
    run <- runs[i,]
    Y <- all_Y %>%
      dplyr::inner_join(run, by = c("pert_time", "pert_name", "pert_mfc_id", "dose"))
    y <- Y$response; names(y) <- Y$ccle_name
    y <- y[is.finite(y)]

    overlap <- dplyr::intersect(rownames(X), names(y))
    y <- y[overlap]

    if (length(y) < 5 | min(y) == max(y)) next

    res.rf <- cdsrmodels::random_forest(X[overlap,], y)
    res.model <- res.rf$model_table %>%
      dplyr::distinct(MSE, MSE.se, R2, PearsonScore) %>%
      dplyr::mutate(model = model,
                    pert_mfc_id = run$pert_mfc_id,
                    pert_name = run$pert_name,
                    pert_time = run$pert_time,
                    dose = run$dose)
    res.features <- res.rf$model_table %>%
      dplyr::distinct(feature, RF.imp.mean, RF.imp.sd, RF.imp.stability, rank) %>%
      dplyr::mutate(model = model,
                    pert_mfc_id = run$pert_mfc_id,
                    pert_name = run$pert_name,
                    pert_time = run$pert_time,
                    dose = run$dose)
    random_forest_table[[ix]] <- res.features; model_table[[ix]] <- res.model
    ix <- ix + 1
  }
}
random_forest_table %<>% dplyr::bind_rows(); model_table %<>% dplyr::bind_rows()

# write results to project folder
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = T)
readr::write_csv(linear_table, paste0(output_dir, "/continuous_associations.csv"))
readr::write_csv(discrete_table, paste0(output_dir, "/discrete_associations.csv"))
readr::write_csv(random_forest_table, paste0(output_dir, "/RF_table.csv"))
readr::write_csv(model_table, paste0(output_dir, "/Model_table.csv"))
