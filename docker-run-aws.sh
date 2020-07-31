#!/usr/bin/env bash




docker run --rm \
    --name foobar \
    -v /Users/jasiedu/Desktop/PDEV_PR300PLUS/RITA:/data \
    -v /Users/jasiedu/.taiga:/root/.taiga \
  -v /Users/jasiedu/WebstormProjects/mts_biomarker/results/RITA2:/out \
  -e projects="Validation Compounds MTS013,German MTS013,GPER Agonist Ridky MTS013,FG-4592 Kaelin MTS013" \
  -e AWS_BATCH_JOB_ARRAY_INDEX=0 \
  -it cmap/mts_biomarker -i /data -o /out

