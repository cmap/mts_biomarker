#!/bin/bash

# read in flagged arguments
while getopts ":i:o:" arg; do
  case $arg in
    i) # specify input folder
      data_dir=${OPTARG}
      ;;
    o) # specifcy output folder
      output_dir=${OPTARG}
  esac
done

Rscript /run_script.R "${data_dir}" "${output_dir}"
