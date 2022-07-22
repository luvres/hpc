FROM rockylinux:8.6

COPY mpi_hello_world.c /root/


RUN dnf -y install \
      dnf-plugins-core \
      epel-release \
      http://repos.openhpc.community/OpenHPC/2/CentOS_8/$(uname -m)/ohpc-release-2-1.el8.$(uname -m).rpm \
  \
  && dnf config-manager --set-enabled powertools \
  && dnf -y install omb-gnu9-mpich-ohpc lmod-ohpc \
  \
  && dnf -y clean all \
  \
  && source /etc/profile.d/lmod.sh \
  && module load gnu9 mpich \
  && mpicc -o /usr/local/bin/mpi_hello_world /root/mpi_hello_world.c \
  && chmod +x /usr/local/bin/mpi_hello_world
  
ENTRYPOINT ["/bin/sh", "-c", "source /etc/profile.d/lmod.sh; module load gnu9 mpich; exec /usr/local/bin/mpi_hello_world"]
