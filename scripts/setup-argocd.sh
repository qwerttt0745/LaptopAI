#!/bin/bash
set -e

ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

ARGOCD_NEW_PASSWORD=$(aws ssm get-parameter \
  --name "/laptopai/dev/argocd-password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region eu-central-1)

argocd login localhost:9090 \
  --username admin \
  --password "$ARGOCD_PASSWORD" \
  --insecure

argocd account update-password \
  --current-password "$ARGOCD_PASSWORD" \
  --new-password "$ARGOCD_NEW_PASSWORD"

argocd repo add https://github.com/qwerttt0745/LaptopAI \
  --username qwerttt0745 \
  --password "$1" \
  --insecure-skip-server-verification

kubectl apply -f k8s/argocd/applications/dev-apps.yaml