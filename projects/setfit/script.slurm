#!/bin/bash
#SBATCH --partition=gpu-rtx3090      # -p
#SBATCH --gres=gpu:rtx3090:2         # 1 GPU per node
#SBATCH --constraint=GPU             # -C feature
#SBATCH --nodes=1                    # -N | node count, 1 nodes reserved
#SBATCH --time=7-00:00:00            # -t | total run time limit (d-HH:MM:SS)
#SBATCH --output=./logs/slurm.log    # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
export APPTAINER_BIND="/scratch/$USER,/scratch/LLM"
export CONTAINER_FILE="/opt/images/llm.sif"
###########
# Options:
# --dataframe_name, example: 'decisoes-ohe-root-text-explode-clean-10w-samples1000.parquet'
# 			decisoes-ohe-root-text-explode-clean-10w-
# 					{ samples1000 | samples5000 | samples10000 | samples25000 | samples50000 | samples100000 }
# 			.parquet
# --model_name, example: 'paraphrase-multilingual-mpnet-base-v2' | 'multilingual-e5-large'
#################################
apptainer run --nv ${CONTAINER_FILE} python -u SetFit-Optimization.py \
\
--dataframe_path '/scratch/luvres' \
--dataframe_name 'decisoes-ohe-root-text-explode-clean-10w-samples100000.parquet' \
\
--model_path 'Sentence_Similarity' \
--model_name 'paraphrase-multilingual-mpnet-base-v2' \
\
--num_samples 1024 \
--n_trials 20 \
\
--inference \
\
"O filho do meu vizinho quebrou a minha janela" \
"Como se aplica uma ação de desapropriação"

