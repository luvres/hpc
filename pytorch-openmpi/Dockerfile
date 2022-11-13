FROM nvidia/cuda:11.8.0-cudnn8-runtime-rockylinux8
MAINTAINER Leonardo Loures <luvres@hotmail.com>

RUN \
  dnf -y install \
      dnf-plugins-core \
      epel-release \
      http://repos.openhpc.community/OpenHPC/2/CentOS_8/$(uname -m)/ohpc-release-2-1.el8.$(uname -m).rpm \
  \
  && dnf config-manager --set-enabled powertools \
  && dnf -y install \
        omb-gnu9-openmpi4-ohpc \
        lmod-ohpc \
        python39-pip \
  \
  && dnf -y clean all \
  \
  # Install PyTorch
  && pip3 --no-cache-dir install --upgrade pip \
  \
  && pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu118/ "torch"
