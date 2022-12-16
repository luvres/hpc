# Build
```docker build -t izone/hpc:tf1.15.5-gpu-py3 -f Dockerfile .```

# Push
```docker push izone/hpc:tf1.15.5-gpu-py3```

# Apptainer
### build
```apptainer build ./tensorflow-summarization.sif ./tensorflow-summarization.def```

### build from docker image
```apptainer pull tensorflow-summarization.sif docker://izone/hpc:tf1.15.5-gpu-py3```

# Run
```apptainer run --nv ./tensorflow-summarization.sif python -c "import tensorflow as tf;tf.test.is_gpu_available()"```

-----

git clone --branch=short-test https://github.com/daysonn/long-summarization.git
cd long-summarization

docker run --rm --gpus all -ti tensorflow/tensorflow:1.15.5-gpu-py3 bash
1) ./run_train.sh
2) ./run_test.sh

import tensorflow as tf
import horovod.tensorflow as hvd

# Initialize Horovod
hvd.init()

# Pin GPU to be used to process local rank (one GPU per process)
config = tf.ConfigProto()
config.gpu_options.visible_device_list = str(hvd.local_rank())
