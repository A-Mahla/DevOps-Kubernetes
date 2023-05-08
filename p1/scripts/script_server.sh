#!/bin/sh

# install ifconfig
apt-get update && apt-get install -y net-tools

# SSH Configuration without pass
cat /tmp/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys 

# install k3s
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="--node-ip=192.168.56.110" \
K3S_KUBECONFIG_MODE="644" sh -
K3S_TOKEN="/var/lib/rancher/k3s/server/node-token" ; while [ ! -e ${K3S_TOKEN} ] ;do sleep 1 ; done
cp ${K3S_TOKEN} /token/
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
echo 'export PATH=$PATH:/usr/sbin' >> /home/vagrant/.bashrc
