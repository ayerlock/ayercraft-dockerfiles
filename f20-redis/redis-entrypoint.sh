#!/bin/bash

fix_config() {
	echo -e "  Changing redis logfile to:\t/tmp/redis.log"
	sed -i -r "s/\/var\/log\/redis\/redis.log/\/tmp\/redis.log/g" /etc/redis.conf
}

# Call all functions
fix_config

# Execute Entrypoint CMD
echo
echo -e "  Entrypoint Called:\t\"$@\""
echo

exec $@
