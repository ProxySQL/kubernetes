FROM proxysql/proxysql:2.0.10

MAINTAINER Nikolaos Vyzas <nick@proxysql.com>

RUN apt update && apt -y install mysql-client && apt clean all

ENTRYPOINT ["proxysql", "-f", "-D", "/var/lib/proxysql"]

