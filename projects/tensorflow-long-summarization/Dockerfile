FROM tensorflow/tensorflow:1.15.5-gpu-py3
MAINTAINER Leonardo Loures <luvres@hotmail.com>

RUN \
  pip --no-cache-dir install --upgrade pip \
  \
  && pip install --no-cache-dir \
        pandas \
        pyrouge \
        tabulate \
        nvidia-pyindex \
        horovod
