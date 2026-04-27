#!/bin/bash
set -e
export HOME=/root
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

dd if=/dev/zero of=/swapfile bs=128M count=16
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

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

until kubectl get nodes | grep -q Ready; do
  sleep 5
done

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

cat > /usr/local/bin/ecr-refresh.sh << 'EOF'
#!/bin/bash
export HOME=/root
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