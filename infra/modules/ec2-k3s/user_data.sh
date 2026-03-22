#!/bin/bash
set -e

yum update -y
yum install -y git cronie

systemctl enable crond
systemctl start crond

PUBLIC_IP=$(curl -s icanhazip.com)

curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --tls-san $PUBLIC_IP

systemctl enable k3s
systemctl start k3s

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

until kubectl get nodes | grep -q Ready; do
  sleep 5
done

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

cat > /usr/local/bin/ecr-refresh.sh << 'EOF'
#!/bin/bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
TOKEN=$(aws ecr get-login-password --region eu-central-1)
cat > /etc/rancher/k3s/registries.yaml << YAML
configs:
  "968909453204.dkr.ecr.eu-central-1.amazonaws.com":
    auth:
      username: AWS
      password: "${TOKEN}"
YAML
systemctl restart k3s
sleep 30
until kubectl get nodes | grep -q Ready; do
  sleep 5
done
EOF

chmod +x /usr/local/bin/ecr-refresh.sh
/usr/local/bin/ecr-refresh.sh

echo "0 */6 * * * root /usr/local/bin/ecr-refresh.sh" > /etc/cron.d/ecr-refresh

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=ClusterIP \
  --wait --timeout 5m

until kubectl get pods -n argocd | grep argocd-server | grep -q Running; do
  sleep 10
done

sleep 30

ARGOCD_INITIAL_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

ARGOCD_NEW_PASSWORD=$(aws ssm get-parameter \
  --name "/laptopai/dev/argocd-password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region eu-central-1)

GITHUB_PAT=$(aws ssm get-parameter \
  --name "/laptopai/dev/github-pat" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region eu-central-1)

argocd login localhost:8080 \
  --username admin \
  --password $ARGOCD_INITIAL_PASSWORD \
  --insecure

argocd account update-password \
  --current-password $ARGOCD_INITIAL_PASSWORD \
  --new-password $ARGOCD_NEW_PASSWORD

argocd repo add https://github.com/qwerttt0745/LaptopAI \
  --username qwerttt0745 \
  --password $GITHUB_PAT \
  --insecure-skip-server-verification

kubectl apply -f https://raw.githubusercontent.com/qwerttt0745/LaptopAI/main/k8s/argocd/applications/dev-apps.yaml

PUBLIC_IP=$(curl -s icanhazip.com)

aws ssm put-parameter \
  --name "/laptopai/dev/kubeconfig" \
  --value "$(cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$PUBLIC_IP/g")" \
  --type SecureString \
  --overwrite \
  --region eu-central-1