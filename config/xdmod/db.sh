#!/bin/bash
sleep 9
mysql < /var/db/xdmod.sql
acl-config
xdmod-slurm-helper -r hpcc
xdmod-ingestor

