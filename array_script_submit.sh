#!/bin/bash
#SBATCH -t 0-12:00

SUBMIT_SCRIPT=$1
FOLDER_NAME=$2
MODEL_DIR=$3
DATA_FILENAME=$4
OUT_FOLDER=$5
OUTPUT_FILENAME=$6
MODEL_TYPE=$7

NO_FILES=$(ls -1 "$FOLDER_NAME"| wc -l)


job_array_id=$(sbatch --array=1-$NO_FILES "$SUBMIT_SCRIPT" "$MODEL_DIR" "$DATA_FILENAME" "$OUT_FOLDER" "$OUTPUT_FILENAME" "$MODEL_TYPE"| awk '{print $NF}')
echo "Job Array ID: $job_array_id"

sleep 1

#Waiting for all jobs to finish to concatanate output files
while squeue --job "$job_array_id" | grep -q "R\| PD"; do
  echo "Waiting for job array $job_array_id to finish."
  sleep 30
done

echo "All jobs in array have completed. Proceeding with concatanating the output files."

head -n 1 "${OUTPUT_FILENAME}_1.csv" > "${OUTPUT_FILENAME}_all.csv"
echo "Added header to output file."

for file in "${OUTPUT_FILENAME}_"*[0-9]*.csv; do
  tail -n +2 "$file" >> "${OUTPUT_FILENAME}_all.csv"
  echo "Added new line to output file from $file."
done

rm "${OUTPUT_FILENAME}_"*[0-9]*.csv