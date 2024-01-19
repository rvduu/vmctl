#!/bin/bash

sed -i '/DHCP_HOSTNAME=.*/d' /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DHCP_HOSTNAME=\"$(hostname)\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart
