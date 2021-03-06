#!/usr/bin/env bash

set -e
set -x

rm -rf /dev/.udev/ > /dev/null 2>&1
rm -rf /var/mail/* > /dev/null 2>&1
rm -rf /var/lib/dhcp/* > /dev/null 2>&1
rm -rf /etc/zypp/locks > /dev/null 2>&1

# remove wicked xml to clean dhcp client id
rm /var/lib/wicked/* > /dev/null 2>&1

rm /etc/udev/rules.d/70-persistent-net.rules

sed -i /HWADDR/d /etc/sysconfig/network/ifcfg-eth0

cat << 'EOF' > /etc/init.d/ssh_gen_host_keys
#!/bin/sh
#
# Generates new ssh host keys on first boot
#
# chkconfig: - 2345 02
# description: Generates new ssh host keys on first boot

### BEGIN INIT INFO
# Provides: ssh_gen_host_keys
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop:
# Short-Description: Generates new ssh host keys on first boot
# Description: Generates new ssh host keys on first boot
### END INIT INFO
rm -f /etc/ssh/ssh_host_*

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ""
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ""
systemctl disable ssh_gen_host_keys

rm -f /etc/init.d/ssh_gen_host_keys
EOF

chmod a+x /etc/init.d/ssh_gen_host_keys
systemctl enable ssh_gen_host_keys

# bsc#1039656 Bring back the good /etc/hosts if Yast2 cleared it
[[ -e /etc/hosts.YaST2save ]] && mv /etc/hosts.YaST2save /etc/hosts

exit 0
