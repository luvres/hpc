FROM rockylinux:8.7
MAINTAINER Leonardo Loures <luvres@hotmail.com>
#################################
# docker build -t izone/desktop:miniconda-orange -f Dockerfile.miniconda.orange .
# docker push izone/desktop:miniconda-orange
# docker pull izone/desktop:miniconda-orange
# docker run --rm -v /mnt:/mnt -ti izone/desktop:miniconda-orange bash
# cp /opt/miniconda.tar.gz /mnt
# ctrl^c
# sudo mv /mnt /opt
# cd /opt
# sudo tar xf miniconda.tar.gz
# sudo rm -fR miniconda.tar.gz
#################################
ENV PATH="$PATH:/opt/miniconda/bin"

RUN \
  dnf install -y rsync && dnf clean all \
  \
  && curl -L https://repo.anaconda.com/miniconda/Miniconda3-py39_23.1.0-1-Linux-x86_64.sh -o /opt/miniconda.sh \
  && bash /opt/miniconda.sh -b -p /opt/miniconda \
  \
  && export PATH="$PATH:/opt/miniconda/bin" \
  \
  && conda update -n base -c defaults conda \
  && conda config --add channels conda-forge \
  && conda config --set channel_priority strict \
  \
  # Install and config Orange
  && conda install pyqt \
  && conda install orange3 \
  && conda install orange3-text \
  && conda install orange3-timeseries \
  && conda install orange3-imageanalytics \
  \
#  && conda install orange3-bioinformatics \
#  && conda install orange3-educational \
#  && conda install orange3-geo \
#  && conda install orange3-associate \
#  && conda install orange3-network \
#  && conda install orange3-explain \
  \
  && dnf clean all \
  \
  && cd /opt && tar cf miniconda.tar.gz miniconda/ && rm miniconda/ -fR
