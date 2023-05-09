#!/bin/sh

# Helm installation
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

sudo kubectl apply -f ../confs/nginx.yaml

# Gitlab
sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update
sudo helm upgrade  --timeout 600s --install --create-namespace --namespace gitlab gitlab gitlab/gitlab -f ../confs/gitlab.values.yaml
sudo kubectl wait --for=condition=Ready pods --all -n gitlab

# Nextcloud
sudo helm repo add nextcloud https://nextcloud.github.io/helm/
sudo helm repo update
sudo helm upgrade  --timeout 600s --install --create-namespace --namespace nextcloud nextcloud nextcloud/nextcloud -f ../confs/nextcloud.values.yaml
sudo kubectl wait --for=condition=Ready pods --all -n nextcloud

# Monitoring - loki stack
sudo helm repo add grafana https://grafana.github.io/helm-charts
sudo helm repo update
sudo helm upgrade  --timeout 600s --install loki --create-namespace --namespace monitoring grafana/loki-stack --values ../confs/loki-stack.values.yaml
sudo kubectl wait --for=condition=Ready pods --all -n monitoring

# Get gitlab pass => username: root
sudo kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d && echo
# Get gitlab pass => username: admin?
sudo kubectl get secret --namespace monitoring loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Deploy new dev application 
sudo kubectl apply -n argocd -f ../confs/argocd_app.yaml
