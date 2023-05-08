#!/bin/sh

# install ifconfig
apt-get update && apt-get install -y net-tools

# SSH Configuration without pass
cat /tmp/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

# install k3s
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="--node-ip=192.168.56.111" \
K3S_URL=https://192.168.56.110:6443 \
K3S_TOKEN=$(cat /token/node-token) sh -
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
echo 'export PATH=$PATH:/usr/sbin' >> /home/vagrant/.bashrc
