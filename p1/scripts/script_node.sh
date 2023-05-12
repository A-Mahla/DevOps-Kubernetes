#!/bin/sh
DEBIAN_FRONTEND=noninteractive

# SSH authorisation from host
mkdir -p /root/.ssh
mv /tmp/id_rsa.pub  /root/.ssh/
chown root:root  /root/.ssh/id_rsa.pub
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 400 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys

# Install k3s as worker server
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=enp0s8" \
K3S_URL=https://192.168.56.110:6443 \
K3S_TOKEN=$(cat /vagrant/node-token) sh -
