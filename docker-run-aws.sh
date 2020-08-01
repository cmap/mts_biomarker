#!/usr/bin/env bash




docker run --rm \
    --name foobar \
    -v /Users/jasiedu/Desktop/PDEV_PR300PLUS/RITA:/data \
    -v /Users/jasiedu/.taiga:/root/.taiga \
  -v /Users/jasiedu/WebstormProjects/mts_biomarker/results/RITA2:/out \
  -e projects='[ { "project_id": "PDEV_PR300PLUS", "pert_name": "bortezomib" }, { "project_id": "PDEV_PR300PLUS", "pert_name": "lapatinib" }]' \
  -e AWS_BATCH_JOB_ARRAY_INDEX=0 \
  -it cmap/mts_biomarker -i /data -o /out

