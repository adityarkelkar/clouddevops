#!/bin/bash

# Pass controller-0, controller-1 and controller-2 as command line argument and run this script thrice

KEY_PAIR_NAME=~/Downloads/dockerubuntu.pem

# Bootstrapping the etcd Cluster
external_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" \
  --output text --query 'Reservations[].Instances[].PublicIpAddress')
ssh -i $KEY_PAIR_NAME ubuntu@${external_ip} <<ADI

wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz"
tar -xvf etcd-v3.3.13-linux-amd64.tar.gz
sudo mv etcd-v3.3.13-linux-amd64/ /usr/local/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

ETCD_NAME=$(curl -s http://169.254.169.254/latest/user-data/ | tr "|" "\n" | grep "^name" | cut -d"=" -f2)
echo "${ETCD_NAME}"

cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv etcd.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

ETCDCTL_API=3 etcdctl member list
ADI
exit