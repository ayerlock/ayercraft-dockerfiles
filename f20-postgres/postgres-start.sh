#!/bin/bash
set -e

PG_VERSION="9.3"
PGBINDIR="/usr/bin"
PGROOT="/var/lib/pgsql"
PGDATA="${PGROOT}/data"
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}

if [[ ! -f ${PGROOT}/setup-complete ]];then
	rm -rf ${PGROOT}/*
	chown -R postgres:postgres ${PGROOT}

	sed -i -e '2,2ialias system=echo' -e '2,2ifunction systemctl() { echo "Environment=PGPORT=5432 PGDATA=/var/lib/pgsql/data"; }' /usr/bin/postgresql-setup && \
	( tail -F /var/lib/pgsql/initdb.log & tailpid=$!; export $(locale 2>>/dev/null|tr -d '\\"') ; /usr/bin/postgresql-setup initdb && \
	kill $tailpid )

	if [[ -f $PGDATA/postgresql.conf ]];then
		sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA/postgresql.conf"
	fi

	if [[ -f $PGDATA/pg_hba.conf ]];then
		sed -i -r 's/^host.*ident$/#&/g' ${PGDATA}/pg_hba.conf
		sed -i -r 's/^local.*peer$/#&/g' ${PGDATA}/pg_hba.conf
		echo -e 'local\tall\tall\t\t\tmd5' >> "$PGDATA/pg_hba.conf"
		echo -e 'host\tall\tall\t0.0.0.0/0\tmd5' >> "$PGDATA"/pg_hba.conf
	fi

	if [ -n "${DB_USER}" ]; then
		if [ -z "${DB_PASS}" ]; then
			echo ""
			echo "WARNING: "
			echo "  Please specify a password for \"${DB_USER}\". Skipping user creation..."
			echo ""
			DB_USER=
		else
			echo "Creating user \"${DB_USER}\"..."
			echo "CREATE ROLE ${DB_USER} with LOGIN CREATEDB PASSWORD '${DB_PASS}';" | \
			/usr/local/bin/gosu postgres ${PGBINDIR}/postgres \
			  --single \
			  -D ${PGDATA} \
			  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
			#sudo -u postgres \
			#  -H ${PGBINDIR}/postgres \
			#  --single \
			#  -D ${PGDATA} \
			#  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
		fi
	fi

	if [ -n "${DB_NAME}" ]; then
		echo "Creating database \"${DB_NAME}\"..."
		echo "CREATE DATABASE ${DB_NAME};" | \
		/usr/local/bin/gosu postgres ${PGBINDIR}/postgres \
		  --single \
		  -D ${PGDATA} \
		  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
		#sudo -u postgres \
		#  -H ${PGBINDIR}/postgres \
		#  --single \
		#  -D ${PGDATA} \
		#  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
	
		if [ -n "${DB_USER}" ]; then
			echo "Granting access to database \"${DB_NAME}\" for user \"${DB_USER}\"..."
			echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};" | \
		/usr/local/bin/gosu postgres ${PGBINDIR}/postgres \
			  --single \
			  -D ${PGDATA} \
			  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
		#	sudo -u postgres \
		#	  -H ${PGBINDIR}/postgres \
		#	  --single \
		#	  -D ${PGDATA} \
		#	  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
		fi
	fi
	touch $PGROOT/setup-complete
fi
	
/usr/bin/supervisord -n -c /etc/supervisord.conf
