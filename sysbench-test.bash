#!/bin/bash
. constants

PREP_THREADS=10
RUN_THREADS=100
NUM_TABLES=10
SIZE_TABLES=10000
REPORT_INTERVAL=5
TIME=600

MYSQL_PWD=XHCO2ydDXj
PORT=26033
HOSTNAME=$(minikube ip)

printf "$RED[$(date)] Dropping 'sysbench' schema if present and preparing test dataset:$NORMAL\n"
mysql -h$HOSTNAME -P$PORT -uroot -p$MYSQL_PWD -e"DROP DATABASE IF EXISTS sysbench; CREATE DATABASE IF NOT EXISTS sysbench"

printf "$POWDER_BLUE[$(date)] Running Sysbench Benchmarks against ProxySQL:"
sysbench /usr/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$PREP_THREADS \
 --mysql-db=sysbench --mysql-user=root --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT --db-driver=mysql prepare

sleep 5

sysbench /usr/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$RUN_THREADS \
 --mysql-db=sysbench --mysql-user=root --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT \
 --time=$TIME --report-interval=$REPORT_INTERVAL --db-driver=mysql --mysql-ignore-errors=all run

#sysbench /usr/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$RUN_THREADS \
# --mysql-db=sysbench --mysql-user=root --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT \
# --time=$TIME --report-interval=$REPORT_INTERVAL --db-driver=mysql run


printf "$POWDER_BLUE$BRIGHT[$(date)] Benchmarking COMPLETED!$NORMAL\n"
