#!/bin/bash
set -e

PG_VERSION="9.3"
PGBINDIR="/usr/bin"
PGROOT="/var/lib/pgsql"
PGDATA="${PGROOT}/data"
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}

createdb_database() {
	if [ -n "${DB_NAME}" ]; then
		echo -e "Creating database:\t${DB_NAME}"
		echo "CREATE DATABASE ${DB_NAME};" | \
		/usr/local/bin/gosu postgres ${PGBINDIR}/postgres \
		  --single \
		  -D ${PGDATA} \
		  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
	
		if [ -n "${DB_USER}" ]; then
			echo -e "  Granting access to database:\t${DB_USER}@${DB_NAME}"
			echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};" | \
			/usr/local/bin/gosu postgres ${PGBINDIR}/postgres \
			  --single \
			  -D ${PGDATA} \
			  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
		fi
	fi
}

createdb_user() {
	if [ -n "${DB_USER}" ]; then
		if [ -z "${DB_PASS}" ]; then
			echo;echo -e "WARNING:\tPlease specify a password for \"${DB_USER}\". Skipping user creation...";echo
			DB_USER=""
		else
			echo -e "Creating database user:\t${DB_USER}"
			echo "CREATE ROLE ${DB_USER} with LOGIN CREATEDB PASSWORD '${DB_PASS}';" | \
			/usr/local/bin/gosu postgres ${PGBINDIR}/postgres \
			  --single \
			  -D ${PGDATA} \
			  -c config_file=${PGDATA}/postgresql.conf >/dev/null 2>&1
		fi
	fi
}

createlock() {
	touch ${PGROOT}/pgsetup.lock
}

fix_pg_access() {
	if [[ -f ${PGDATA}/pg_hba.conf ]];then
		sed -i -r 's/^host.*ident$/#&/g' ${PGDATA}/pg_hba.conf
		sed -i -r 's/^local.*peer$/#&/g' ${PGDATA}/pg_hba.conf
		echo -e 'local\tall\tall\t\t\tmd5' >> ${PGDATA}/pg_hba.conf
		echo -e 'host\tall\tall\t0.0.0.0/0\tmd5' >> ${PGDATA}/pg_hba.conf
	fi
}

fix_pg_config() {
	if [[ -f $PGDATA/postgresql.conf ]];then
		sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "${PGDATA}/postgresql.conf"
	fi
}

fix_pg_rights() {
	chown -R postgres:postgres ${PGROOT}
}

fix_super_config() {
	sed -i -r "s/-p 5432/-p ${PGPORT}/g"
}

setup_postgres() {
	sed -i -e '2,2ialias system=echo' -e '2,2ifunction systemctl() { echo "Environment=PGPORT=5432 PGDATA=/var/lib/pgsql/data"; }' /usr/bin/postgresql-setup && \
	( tail -F /var/lib/pgsql/initdb.log & tailpid=$!; export $(locale 2>>/dev/null|tr -d '\\"') ; /usr/bin/postgresql-setup initdb && \
	kill $tailpid )
}

# Setup the Postgres Database
# note: in the event we are using an external volume, we dont want to overwrite it if its to be reused.  This section creates a lock file after
#   setup has completed to prevent it from running on the external volume if it is reattached to a different container later on.
if [[ ! -f ${PGROOT}/pgsetup.lock ]];then
	rm -rf ${PGROOT}/*
	fix_pg_rights
	setup_postgres
	fix_pg_config
	fix_pg_access
	createdb_user
	createdb_database
	createlock
else
	fix_pg_rights
fi
	
# Execute our entry command
exec $@
