#!/bin/bash
set -e

mbin="/usr/bin/mysql"
lcon="-h127.0.0.1 -P6032 -uadmin -padmin"
opts="-NB"

hg0_avail=$($mbin $lcon $opts -e"select count(*) from runtime_mysql_servers where hostgroup_id = 0")

if [[ $hg0_avail -eq 1 ]];
then
  echo "HG0 Availability Success"
  exit 0
else
  echo "HG0 Availability Failure - MySQL backends found: $hg0_avail"
  exit 1
fi
