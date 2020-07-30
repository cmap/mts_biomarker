#!/usr/bin/env bash
# -i = full path to data directory (single project or compound)
# -o = full path to output directory

docker run -it -v /Users/jasiedu/Desktop/PDEV_PR300PLUS/RITA:/data \
  -v /Users/jasiedu/.taiga:/root/.taiga \
  -v /Users/jasiedu/WebstormProjects/mts_biomarker/results/RITA2:/out \
  cmap/mts_biomarker -i /data -o /out
