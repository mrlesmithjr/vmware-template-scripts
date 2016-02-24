#!/bin/bash

#add VMware package keys
wget http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub -O - | apt-key add - wget http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub -O - | apt-key add -

#grab Ubuntu Codename
codename="$(lsb_release -c | awk {'print $2}')"

#add VMware repository to install open-vm-tools-deploypkg
echo "deb http://packages.vmware.com/packages/ubuntu $codename main" > /etc/apt/sources.list.d/vmware-tools.list

#update apt-cache
apt-get update

#install packages
apt-get install -y open-vm-tools-deploypkg open-vm-tools

#Stop services for cleanup
service auditd stop
service rsyslog stop

#clear audit logs
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog

#cleanup persistent udev rules
rm /etc/udev/rules.d/70-persistent-net.rules

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm /etc/ssh/ssh_host_*

#add check for ssh keys on reboot...regenerate if neccessary
sed -i -e 's|exit 0||' /etc/rc.local
sed -i -e 's|.*test -f /etc/ssh/ssh_host_dsa_key.*||' /etc/rc.local
bash -c 'echo "test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server" >> /etc/rc.local'
bash -c 'echo "exit 0" >> /etc/rc.local'

#reset hostname
cat /dev/null > /etc/hostname

#cleanup apt
apt-get clean

#cleanup shell history
history -w
history -c
