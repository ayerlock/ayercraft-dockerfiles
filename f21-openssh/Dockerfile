FROM docker.lab/fedora-21
MAINTAINER Michael J. Ayers <ayersm@gmail.com>

RUN yum -y update && yum -y install openssh-server supervisor && yum clean all
RUN mkdir /var/run/sshd

ADD ./supervisord.conf /etc/supervisord.conf
ADD ./supervisord-sshd.conf /etc/supervisord.d/sshd.conf
ADD ./openssh-entrypoint.sh /openssh-entrypoint.sh
RUN chmod 755 /openssh-entrypoint.sh && chmod 600 /etc/supervisord.conf /etc/supervisord.d/*

ENTRYPOINT ["/openssh-entrypoint.sh"]
EXPOSE 22
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
