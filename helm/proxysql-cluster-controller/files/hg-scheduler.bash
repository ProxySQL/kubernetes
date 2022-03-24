#!/bin/bash
CUR_CS=$(/usr/bin/md5sum $0 | /usr/bin/awk '{print $1}')
PRE_CS=$(/bin/cat /tmp/cs.file | /usr/bin/awk '{print $1}')

if [[ $CUR_CS != $PRE_CS ]];
then
  /bin/echo "Diffs detected, executing"
  /usr/bin/mysql -uadmin -padmin -h127.0.0.1 -P6032 -e"
    DELETE FROM mysql_servers;
    INSERT INTO mysql_servers (hostgroup_id,hostname,port,max_replication_lag,comment,max_connections)
      VALUES (0,'mysql-8.default.svc.cluster.local',3306,90,'mysql-master-1',5000);
    INSERT INTO mysql_servers (hostgroup_id,hostname,port,max_replication_lag,comment,max_connections) 
      VALUES (1,'mysql-8-slave.default.svc.cluster.local',3306,90,'mysql-slave-1',5000);


    DELETE FROM mysql_replication_hostgroups;
    INSERT INTO mysql_replication_hostgroups (writer_hostgroup,reader_hostgroup,comment) VALUES (0,1,'');
    LOAD MYSQL SERVERS TO RUNTIME;
    SAVE MYSQL SERVERS TO DISK;

    DELETE FROM mysql_users;
    INSERT INTO mysql_users (username,password,default_hostgroup,active) VALUES ('root','XHCO2ydDXj',0,1);
    INSERT INTO mysql_users (username,password,default_hostgroup,active) VALUES ('monitor','monitor',0,1);
    LOAD MYSQL USERS TO RUNTIME;
    SAVE MYSQL USERS TO DISK; 

    DELETE FROM mysql_query_rules;
    INSERT INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply)
      VALUES (1,1,'^SELECT.*FOR UPDATE',0,1),(2,1,'^SELECT',1,1);
    LOAD MYSQL QUERY RULES TO RUNTIME;
    SAVE MYSQL QUERY RULES TO DISK;

    DELETE FROM proxysql_servers;
    INSERT INTO proxysql_servers (hostname,port,weight,comment) 
      VALUES ('proxysql-cluster-controller',6032,0,'proxysql-cluster-controller');
    LOAD PROXYSQL SERVERS TO RUNTIME;
    SAVE PROXYSQL SERVERS TO DISK;


  "
  /bin/echo $CUR_CS > /tmp/cs.file
fi

