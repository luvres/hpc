# Build
```docker build -t izone/hpc:lightning-cu11.8-py310-ubuntu22 -f Dockerfile .```

# Push
```docker push izone/hpc:lightning-cu11.8-py310```

# Apptainer
```apptainer pull lightning.sif docker://izone/hpc:lightning-cu11.8-py310```

# Run
```apptainer run --nv ./lightning.sif python -c "import torch;print(torch.cuda.is_available())"```
