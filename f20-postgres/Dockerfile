FROM docker.lab.ayercraft.net/fedora-20
MAINTAINER Michael J. Ayers <ayersm@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.5-2.fc20
ENV PGDATA /var/lib/pgsql/data
ENV PGPORT 5432

ADD ./supervisord.conf /etc/supervisord.conf
ADD ./supervisord-postgres.conf /etc/supervisord.d/postgres.conf
ADD ./postgres-entrypoint.sh /

RUN yum -y update && yum -y install postgresql postgresql-server postgresql-contrib supervisor && yum clean all
RUN curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.0/gosu' && chmod +x /usr/local/bin/gosu
RUN chmod 775 /postgres-entrypoint.sh

VOLUME /var/lib/pgsql

USER postgres
WORKDIR /var/lib/pgsql

USER root
ENTRYPOINT ["/postgres-entrypoint.sh"]
EXPOSE 5432

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
