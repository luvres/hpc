FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
MAINTAINER Leonardo Loures <luvres@hotmail.com>

RUN \
  apt update && apt install --yes --no-install-recommends python3-pip \
  && rm -rf /var/lib/apt/lists/* \
  \
  && ln -s /usr/bin/python3 /usr/bin/python \
  \
  # Install PyTorch Lightning
  && pip3 --no-cache-dir install --upgrade pip \
  \
  && pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu118/ "lightning"
