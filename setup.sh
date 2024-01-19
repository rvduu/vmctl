#!/bin/bash

set -eu

install -d $HOME/.local/bin
install -d $HOME/.local/kickstart
install -m 755 vmctl $HOME/.local/bin
install -m 644 fixdhcp.sh $HOME/.local/kickstart

for pkf in id_dsa.pub id_ecdsa.pub id_ecdsa_sk.pub id_ed25519.pub id_ed25519_sk.pub
do
	if [ -f "$HOME/.ssh/$pkf" ]
	then
		pubkeyfile="$HOME/.ssh/$pkf"
		pubkey=$(<$pubkeyfile)
		break
	fi
done

if [ ! -f "$pubkeyfile" ]
then
	echo "No pubkey file found, exiting!"
	exit 1
fi

echo "Please enter the password to use in the kickstart files for root and user1:"
password=$(mkpasswd --method=SHA-512)

for i in rhel*.cfg.IN
do
	if ! [ -f "$HOME/.local/kickstart/$(basename ${i} .IN)" ]
	then
		sed -e "s|__SSHPUBKEY__|${pubkey}|g" -e "s|__PASSWORD__|${password}|g"< "${i}" > \
			"$HOME/.local/kickstart/$(basename ${i} .IN)"
		chmod 644 "$HOME/.local/kickstart/$(basename ${i} .IN)"
	else
		echo "Kickstart file already exists, skipping: $(basename ${i})"
	fi
done
