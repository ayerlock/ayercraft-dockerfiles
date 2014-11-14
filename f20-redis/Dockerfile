FROM docker.lab.ayercraft.net/fedora-20
MAINTAINER Michael J. Ayers <ayersm@gmail.com>

RUN yum -y update &&  yum -y install redis supervisor && yum clean all

ADD ./supervisord.conf /etc/supervisord.conf
ADD ./supervisord-redis.conf /etc/supervisord.d/redis.conf
ADD ./redis-entrypoint.sh /redis-entrypoint.sh
RUN chmod 775 /redis-entrypoint.sh

ENTRYPOINT [ "/redis-entrypoint.sh" ]
EXPOSE 6379

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]
#CMD [ "redis-server" ]
