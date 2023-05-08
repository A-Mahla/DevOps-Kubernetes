
# tools used
sudo apt-get update && \
sudo apt install apt-transport-https curl ca-certificates gnupg wget -y

# install docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && \
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# install k3d and create a cluster
sudo wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
sudo k3d cluster create amahla --servers 1 --agents 1 \
--api-port 6550 \
--port '80:80@loadbalancer' \
--port '8888:8888@loadbalancer' \
--port '443:443@loadbalancer' \
--k3s-arg '--disable=traefik@server:*'


# install kubectl
# install for arm64
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
# install for amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -rf kubectl
alias k='kubectl'

# Install reverse Proxy method and ingress nginx integration
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/baremetal/deploy.yaml
sudo kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
sudo kubectl apply -f ../confs/nginx.yaml
sudo kubectl wait --for=condition=Ready pods --all -n ingress-nginx

# Deploy argocd application
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f ../confs/install.yaml
sudo kubectl wait --for=condition=Ready pods --all -n argocd

# Deploy dev application
sudo kubectl apply -n argocd -f ../confs/dev.yaml

# Get the password => username: admin
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
