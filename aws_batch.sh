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

IFS=',' read -r -a a_projects <<< "${projects}"
batch_index=${AWS_BATCH_JOB_ARRAY_INDEX}
project="${a_projects[${batch_index}]}"
export HDF5_USE_FILE_LOCKING=FALSE

Rscript /run_script.R "${data_dir}/${project}" "${output_dir}/${project}"

exit_code=$?

echo "$exit_code"
exit $exit_code
