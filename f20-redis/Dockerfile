FROM docker.lab.ayercraft.net/fedora-20
MAINTAINER Michael J. Ayers <ayersm@gmail.com>

RUN yum -y update &&  yum -y install redis && yum clean all

EXPOSE 6379

CMD [ "redis-server" ]

