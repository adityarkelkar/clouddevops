#!/bin/bash

# Generating Kubernetes Authentication Files for Authentication

# Client Authentication Config
# Kubernetes Public IP Address
KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers --load-balancer-arns ${LOAD_BALANCER_ARN} \
  --output text --query 'LoadBalancers[0].DNSName')


# The kubelet Kubernetes Configuration Files
mkdir -p cfg

for i in 0 1 2; do
  instance="worker-${i}"
  instance_hostname="ip-10-240-0-2${i}"
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=tls/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=cfg/${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance_hostname} \
    --client-certificate=tls/${instance}.pem \
    --client-key=tls/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=cfg/${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance_hostname} \
    --kubeconfig=cfg/${instance}.kubeconfig

  kubectl config use-context default \
    --kubeconfig=cfg/${instance}.kubeconfig
done

# The kube-proxy Kubernetes Configuration File
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=tls/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=cfg/kube-proxy.kubeconfig
kubectl config set-credentials kube-proxy \
  --client-certificate=tls/kube-proxy.pem \
  --client-key=tls/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=cfg/kube-proxy.kubeconfig
kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig=cfg/kube-proxy.kubeconfig
kubectl config use-context default \
  --kubeconfig=cfg/kube-proxy.kubeconfig

# Distribute the Kubernetes Configuration Files
for instance in worker-0 worker-1 worker-2; do
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ~/Downloads/dockerubuntu.pem \
    cfg/${instance}.kubeconfig cfg/kube-proxy.kubeconfig \
    ubuntu@${external_ip}:~/
done