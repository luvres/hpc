# Fine-Tuning LLaMA2, QLoRA

Requirements from [OVHcloud](https://blog.ovhcloud.com/fine-tuning-llama-2-models-using-a-single-gpu-qlora-and-ai-notebooks/)

### Build
```
docker build -t izone/hpc:llama2 -f Dockerfile .
```

### Push
```
docker push izone/hpc:llama2
```

### Apptainer
```
apptainer build llama2.sif llama2.def
```
```
apptainer pull llama2.sif docker://izone/hpc:llama2
```

### Run docker
```
docker run --rm --gpus all -ti izone/hpc:llama2 nvidia-smi
```
### Run apptainer
```
mkdir cache output logs

sbatch script.slurm
```


srun --partition=gpu-rtx3090 nvidia-smi

apptainer run --nv /opt/images/bc23.sif python -c "import torch;print(torch.cuda.is_available())"


srun --partition=gpu-rtx3090 ./llama2.sif python -c "import torch;print(torch.cuda.is_available())"


# Open-source vector similarity search for Postgres

Project [Github](https://github.com/pgvector/pgvector)

### Run
```
docker run --rm --name pgvector -p 5432:5432 -e POSTGRES_PASSWORD=aamu02 ankane/pgvector

docker run --name pgvector \
--restart unless-stopped \
-p 5432:5432 \
-e POSTGRES_PASSWORD=aamu02 \
-v $PWD/data:/var/lib/postgresql/data \
-d ankane/pgvector
```
### Enable the extension 
```
docker exec -ti pgvector psql -U postgres -c "CREATE EXTENSION vector;"
```
### List extensions
```
docker exec -ti pgvector psql -U postgres -c "\dx"

docker exec -ti pgvector psql -U postgres -c "SELECT * FROM pg_extension;"
```
### Postgres version
```
docker exec -ti pgvector psql -U postgres -c "SELECT version();"
```




