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

#IFS=',' read -r -a a_projects <<< "${projects}"

batch_index=${AWS_BATCH_JOB_ARRAY_INDEX}
export HDF5_USE_FILE_LOCKING=FALSE

pert_name=$(echo "${projects}" | jq -r --argjson index ${batch_index} '.[$index].pert_name')
folder_name=$(echo "${sample}" | jq -r --argjson index ${batch_index} '.[$index].project_id')

echo "${data_dir}/${folder_name}/${pert_name}" "${output_dir}/${folder_name}/${pert_name}"
Rscript /run_script.R "${data_dir}/${folder_name}/${pert_name}" "${output_dir}/${folder_name}/${pert_name}"

exit_code=$?

echo "$exit_code"
exit $exit_code
