FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime
MAINTAINER Leonardo Loures <luvres@hotmail.com>

RUN \
  apt-get update && apt-get install --yes libsndfile1 \
  \
  && pip install --no-cache-dir huggingsound \
  && pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu113/ "torchaudio==0.12.1+cu113"
