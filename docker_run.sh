# -i = full path to data directory (single project or compound)
# -o = full path to output directory

docker run -it -v /Users/aboghoss/Downloads/PDEV:/data \
  -v /Users/aboghoss/.taiga/token:/root/.taiga/token \
  cmap/mts_biomarker -i /data/AZ-628 -o /data/results
