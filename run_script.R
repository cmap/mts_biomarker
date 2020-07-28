# Pass 5 arguments in order as follows:
# args[1] = full path to cell_info file
# args[2] = full path to sig_metrics file
# args[3] = full path to ZSPC combat gct file
# args[4] = full path to output directory. must end with a "/"
# args[5] = the name of the compound

args = commandArgs(trailingOnly=TRUE)
if (length(args) !=5) {
  stop("Supply 5 args. Full path to cell_info, sig_metrics,combat_gct,out_path,compound name in the order specified", call.=FALSE)
}

library(tidyverse)
library(useful)
library(magrittr)
library(cmapR)
library(cdsrbiomarker)

cell_info =  args[1];
sig_metrics =  args[2];
combat_gct = args[3];
out_path = args[4];
compound  = args[5];

# LOAD THE DATA - fairly straightforward, please feel free to modify
cell_info = data.table::fread(cell_info)
sig_info = data.table::fread(sig_metrics) %>%
   dplyr::filter(pert_type == "trt_cp") %>%
   dplyr::distinct(sig_id, pert_time, pert_mfc_id, pert_dose, pert_iname)

data <- parse_gctx(combat_gct)@mat
 rownames(data) = tibble(rid = rownames(data)) %>%
   dplyr::left_join(cell_info %>% dplyr::distinct(rid, cell_id)) %>%
   .$cell_id
 data = data[, sig_info$sig_id]

 dir.create(out_path, recursive=T)
 temp_path = paste0(out_path, compound)
  dir.create(temp_path)
  temp_meta = sig_info %>%
    dplyr::filter(pert_mfc_id == compound)

  write_csv(temp_meta, paste0(temp_path, "/meta_data.csv"))
  write.csv(data[, temp_meta$sig_id], paste0(temp_path, "/data.csv"))
  #res = get_biomarkers(Y = data[, temp_meta$sig_id], out_path = temp_path)
  res = get_biomarkers(Y = data[, temp_meta$sig_id, drop = F], out_path = temp_path).
  generate_multi_profile_biomarker_report(temp_path, compound)

