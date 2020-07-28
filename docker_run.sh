# args[1] = full path to cell_info file
# args[2] = full path to sig_metrics file
# args[3] = full path to LFCVC combat gct file
# args[4] = full path to output directory. must end with a "/"
# args[5] = the name of the compound



#docker run -it --name f3 -v /cmap/PBRANT/PBRANT_DEEP/build/:/data \
#-v /cmap/PBRANT/taiga/token:/root/.taiga/token \
#cmap/cdsr_biomarker \
#/data/PBRANT_DEEP_cell_info.txt /data/PBRANT_DEEP_sig_metrics_MODZ.LFCVC.COMBAT.txt \
#/data/PBRANT_DEEP_LEVEL5_MODZ.LFCVC.COMBAT_n36609x488.gct /data/marker_out/ BRD-C02142012

#docker run -it --name name872 -v /Users/jasiedu/Downloads/PBRANT_DEEP/build/:/data \
#-v /Users/jasiedu/.taiga/token:/root/.taiga/token \
#-v /Users/jasiedu/WebstormProjects/macchiato/dockers/cdsr_biomarker/run_script.R:/scripts/run_script.R \
#cmap/cdsr_biomarker \
#/data/PBRANT_DEEP_cell_info.txt /data/PBRANT_DEEP_sig_metrics_MODZ.LFCVC.COMBAT.txt \
#/data/PBRANT_DEEP_LEVEL5_MODZ.LFCVC.COMBAT_n36609x488.gct /data/marker_out/ BRD-C02142012


docker run -it -v /Users/jasiedu/Downloads/PBRANT/PBRANT_DEEP_CURATED/build/:/data \
-v /Users/jasiedu/Downloads/cdsr_biomarker/token:/root/.taiga/token \
-v /Users/jasiedu/Downloads/cdsr_biomarker/scripts/run_script.R:/scripts/run_script.R \
cmap/cdsr_biomarker \
/data/PBRANT_DEEP_V1_cell_info.txt /data/PBRANT_DEEP_sig_metrics_MODZ.LFCVC.COMBAT.txt \
/data/PBRANT_DEEP_LEVEL5C_MODZ.LFCVC.COMBAT_n32135x488.gct /data/marker_out3/ BRD-C05132474
