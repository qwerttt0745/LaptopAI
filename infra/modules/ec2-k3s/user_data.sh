#!/bin/bash
set -e

yum update -y
yum install -y curl git

curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --disable traefik

systemctl enable k3s
systemctl start k3s

until kubectl get nodes | grep -q Ready; do
  sleep 5
done

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -