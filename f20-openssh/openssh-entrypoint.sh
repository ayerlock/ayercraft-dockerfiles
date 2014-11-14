#!/bin/bash

generate_keys() {
	echo -e "Generating container SSH Host Keys."
	ssh-keygen -q -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N ''
	ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
}

fix_config() {
	sed -i -r 's/#ListenAddress/ListenAddress/g' /etc/ssh/sshd_config
}

get_ipaddr() {
	for IPADDR in `ip addr show | grep inet | grep -Ev '(inet6|127.0.0.1)' | awk '{ print $2 }' | sed -r 's/\/(.*)$//g'`;do
	echo -e "  Container IP Address:\t${IPADDR}"
	done
}

create_user() {
	# Environment configurables: SSHUSER and SSHPASS
	# If they exist, use those for the login account
	# If not create a default user/pass of: sshuser/changeme
	if [[ -z ${SSHUSER} ]];then
		SSHUSER="sshuser"
	fi
	if [[ -z ${SSHPASS} ]];then
		SSHPASS="changeme"
	fi

	echo -e "  Container User Account:\t${SSHUSER}"
	useradd ${SSHUSER}
	echo -e "${SSHPASS}\n${SSHPASS}" | (passwd --stdin ${SSHUSER})
	echo -e "  Container User Password:\t${SSHPASS}"
}

echo
echo -e "  Entrypoint Called:\t\"$@\""
echo

# Call all functions
fix_config
generate_keys
echo
create_user
echo
get_ipaddr
echo

exec $@
