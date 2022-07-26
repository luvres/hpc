#!/bin/bash

source /etc/profile.d/lmod.sh
module load gnu9 mpich
exec /usr/local/bin/lmp "$@"
