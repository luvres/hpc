# Build
```docker build -t izone/hpc:r8-torch1.13.0-cu11.8-py39-ompi -f Dockerfile .```

# Push
```docker push izone/hpc:r8-torch1.13.0-cu11.8-py39-ompi```

# Apptainer
```apptainer pull torch-mpi.sif docker://izone/hpc:r8-torch1.13.0-cu11.8-py39-ompi```

# Run
```apptainer run --nv ./torch-mpi.sif python -c "import torch;print(torch.cuda.is_available())"```

