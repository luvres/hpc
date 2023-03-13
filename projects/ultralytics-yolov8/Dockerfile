FROM nvidia/cuda:11.7.1-base-ubuntu22.04
MAINTAINER Leonardo Loures <luvres@hotmail.com>

RUN apt update && apt install --yes --no-install-recommends python3-pip libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python \
    \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir ultralytics
