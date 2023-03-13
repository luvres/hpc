### Build Apptainer
```apptainer build ultralytics.sif ultralytics.def```

### Build Docker
```docker build -t izone/hpc:ultralytics -f Dockerfile.ultralytics .```

### Push
```docker push izone/hpc:ultralytics```

### build from docker image
```apptainer pull ultralytics.sif docker://izone/hpc:ultralytics```

### Run
```apptainer run --nv ultralytics.sif python -c "import torch;print(torch.cuda.is_available())"```

```apptainer run --nv ultralytics.sif python -c "import ultralytics;ultralytics.checks()"```

-----

