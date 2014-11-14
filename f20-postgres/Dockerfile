FROM docker.lab.ayercraft.net/fedora-20
MAINTAINER Michael J. Ayers <ayersm@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.5-2.fc20
ENV PGDATA /var/lib/pgsql/data
ENV PGPORT 5432

ADD ./supervisord.conf /etc/supervisord.conf
ADD ./postgres-start.sh /

RUN yum -y update && yum clean all && yum -y install postgresql postgresql-server postgresql-contrib supervisor && yum clean all
RUN curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.0/gosu' && chmod +x /usr/local/bin/gosu && chmod 775 /postgres-start.sh

VOLUME /var/lib/pgsql

USER postgres
WORKDIR /var/lib/pgsql

USER root
EXPOSE 5432

CMD ["/postgres-start.sh"]
