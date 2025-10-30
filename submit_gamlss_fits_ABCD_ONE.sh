#### Before running this script: change path for output, should be a folder called "out_messages" inside the out_folder.
#### Change job-name.
#### This script is for split ONE - specify in name of output folder and job name.
#!/bin/bash
#SBATCH --job-name=t1_BCT_ONE
#SBATCH --output=/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/2.0_results/gamlss_fits_t1_BCT_vol_splitONE_2.0/out_messages/%x_%A_%a_output.txt
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G

# Directory containing the model structures
MODEL_DIR=$1
# Name of .csv file with data for fitting
DATA_FILENAME=$2
# path - where to save model fits
OUT_FOLDER=$3
# name of output stats file. Should be out_folder/gamlss_fits_stats.csv
OUTPUT_FILENAME=$4
# whether fitting t1, t2, or longitudinal model
MODEL_TYPE=$5


#Create a temp directory for the current job
TMPDIR=$(mktemp -d /mnt/isilon/bgdlab-processing/Eren/job_${SLURM_ARRAY_TASK_ID}_XXXXXX)
export TMPDIR
cd $TMPDIR

module load R/4.2.3

# Run the R script with the specified model
Rscript /mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/ABCD_premie_code/abcd_gamlss_model_fit.R $SLURM_ARRAY_TASK_ID $MODEL_DIR $DATA_FILENAME $OUT_FOLDER $OUTPUT_FILENAME $MODEL_TYPE

trap "rm -rf $TMPDIR" EXIT