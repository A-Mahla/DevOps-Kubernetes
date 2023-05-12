#!/bin/sh
DEBIAN_FRONTEND=noninteractive

# Install and update dependencies
sudo apt -y update && sudo apt -y upgrade && sudo apt install etcd-server etcd-client -y

# Install k3s without loadBalancer and without reverse-proxy ingress integration
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="--node-ip=192.168.56.110 \
--flannel-iface=enp0s8 \
--write-kubeconfig-mode 644 \
--advertise-address=192.168.56.110 --node-ip=192.168.56.110 \
--kube-apiserver-arg="service-node-port-range=30000-30100" \
--disable=traefik \
--disable=servicelb" \
K3S_STORAGE_BACKEND=etcd3 K3S_STORAGE_ENDPOINT="http://127.0.0.1:2379" sh -
K3S_TOKEN="/var/lib/rancher/k3s/server/node-token" ; while [ ! -e ${K3S_TOKEN} ] ;do sleep 1 ; done
cp ${K3S_TOKEN} /vagrant/
KUBE_CONFIG="/etc/rancher/k3s/k3s.yaml"
mkdir -p ~/.kube/
mkdir -p /root/.kube/
cp ${KUBE_CONFIG} ~/.kube/config
cp ${KUBE_CONFIG} /root/.kube/config
chmod go-r /root/.kube/config

wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod a+x /usr/local/bin/yq

# SSH authorisation from host
mkdir -p /root/.ssh
mv /tmp/id_rsa.pub  /root/.ssh/
chown root:root  /root/.ssh/id_rsa.pub
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 400 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys

# Helm installation
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install loadBalancer
kubectl apply -f /tmp/manifests/metallb.yaml
kubectl wait --for=condition=Ready pods --all -n metallb-system

# Install reverse Proxy method and ingress nginx integration
kubectl apply -f /tmp/manifests/nginx.yaml
kubectl apply -f /tmp/manifests/nginx-ingress-secondary-controller.yaml
kubectl apply -f /tmp/manifests/nginx-ingress-secondary-service.yaml
kubectl wait --for=condition=Ready pods --all -n ingress-nginx
# Ignore fail ingress-nginx-admission
# https://github.com/kubernetes/ingress-nginx/issues/5401 [Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io"]
kubectl get Validatingwebhookconfigurations ingress-nginx-admission -o=yaml | yq '.webhooks[].failurePolicy = "Ignore"' | kubectl apply -f -
# Or delete it
# kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

# Deploy apps
kubectl apply -f /tmp/manifests/app1.yaml -f /tmp/manifests/app2.yaml -f /tmp/manifests/app3.yaml