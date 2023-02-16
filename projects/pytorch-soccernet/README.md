# Build
```docker build -t izone/hpc:pytorch-soccernet -f Dockerfile .```

# Push
```docker push izone/hpc:pytorch-soccernet```

# Apptainer
### build
```apptainer build ./pytorch-soccernet.sif ./pytorch-soccernet.def```

### build from docker image
```apptainer pull pytorch-soccernet.sif docker://izone/hpc:pytorch-soccernet```

# Run
```apptainer run --nv ./pytorch-soccernet.sif python -c "import torch;print(torch.cuda.is_available())"```

