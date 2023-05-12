#!/bin/sh

# Helm installation
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

kubectl apply -f manifests/nginx.yaml

# Gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade  --timeout 600s --install --create-namespace --namespace gitlab gitlab gitlab/gitlab -f ./manifests/gitlab.values.yaml
kubectl wait --for=condition=Ready pods --all -n gitlab

# Nextcloud
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm upgrade  --timeout 600s --install --create-namespace --namespace nextcloud nextcloud nextcloud/nextcloud -f ./manifests/nextcloud.values.yaml
kubectl wait --for=condition=Ready pods --all -n nextcloud

# Monitoring - loki stack
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade  --timeout 600s --install loki --create-namespace --namespace monitoring grafana/loki-stack --values ./manifests/loki-stack.values.yaml
kubectl wait --for=condition=Ready pods --all -n monitoring
# kubectl get secret --namespace monitoring loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
