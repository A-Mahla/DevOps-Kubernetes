#!/bin/sh

# Kubernetes can fail with swap
swapoff -a

DEBIAN_FRONTEND=noninteractive
apt install apt-transport-https curl wget -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt install docker-ce docker-ce-cli containerd.io kubectl joe pbzip2 git openconnect -y
addgroup -a vagrant docker
systemctl enable docker && systemctl enable containerd && systemctl start docker && systemctl start containerd

wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod a+x /usr/local/bin/yq

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
# let's pull the k3s container image once in the base image and reuse it - saves traffic and start up time every time a child image is started
k3d cluster create warmup-cluster --servers 1 --agents 0
k3d cluster delete warmup-cluster
apt-get clean

# SSH authorisation from host
mkdir -p /root/.ssh
mv ./.ssh/id_rsa.pub  /root/.ssh/
chown root:root  /root/.ssh/id_rsa.pub
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 400 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys

# Create k3d node
echo "127.0.1.1 $(hostname)" >> /etc/hosts
k3d cluster create 42demon-cluster1 \
--servers 1 \
--agents 3  \
--api-port 6550 \
--port '80:80@loadbalancer' \
--port '8888:80@loadbalancer' \
--port '443:443@loadbalancer' \
--k3s-arg '--disable=traefik@server:*'


mkdir -p /root/.kube/
KUBE_CONFIG="/root/.kube/config"
k3d kubeconfig get 42demon-cluster1 > ${KUBE_CONFIG} 
chmod go-r /root/.kube/config

# Install reverse Proxy method and ingress nginx integration
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/baremetal/deploy.yaml
## Add loadBalancer service (with static IP)
kubectl apply -f ./manifests/nginx.yaml
kubectl wait --for=condition=Ready pods --all -n ingress-nginx

# ArgoCD
## Without helm
kubectl create namespace argocd
kubectl apply --namespace=argocd -f ./manifests/install_argocd.yaml
kubectl wait --for=condition=Ready pods --all -n argocd
kubectl apply --namespace=argocd -f ./manifests/argocd_app.yaml
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo