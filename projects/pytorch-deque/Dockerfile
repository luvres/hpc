FROM nvcr.io/nvidia/pytorch:22.08-py3
MAINTAINER Leonardo Loures <luvres@hotmail.com>

RUN \
  pip install wget hydra hydra-core torchmetrics seaborn pytorch-lightning==1.6.5 \
  && pip install git+https://github.com/lucasb-eyer/pydensecrf.git
