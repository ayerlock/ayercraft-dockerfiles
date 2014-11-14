FROM docker.lab.ayercraft.net/rhel7
MAINTAINER Michael J. Ayers <ayersm@gmail.com>
 
# Update the image with the latest packages (recommended) and install Apache Web Server
RUN yum update -y && yum install -y mariadb-server && yum clean all && /usr/bin/mysql_install_db
 
# Define working directory.
#WORKDIR /data

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql", "/var/log/mysql"]

# Copy in the entrypoint script
COPY mariadb-start.sh /mariadb-start.sh
ENTRYPOINT ["/mariadb-start.sh"]

# Expose Ports
EXPOSE 3306

# Define default command.
CMD ["mysqld", "--datadir=/var/lib/mysql", "--user=mysql"]
