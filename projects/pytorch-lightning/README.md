# Apptainer
```
apptainer build lightning.sif lightning.def
```
# Run
```
apptainer run --nv ./lightning.sif python -c "import torch;print(torch.__version__)"

apptainer run --nv ./lightning.sif python -c "import torch;print(torch.cuda.is_available())"
```

# Build docker
```
docker build -t izone/hpc:lightning-cu11.8-py310-ubuntu22 -f Dockerfile .
```
# Push
```
docker push izone/hpc:lightning-cu11.8-py310
```

