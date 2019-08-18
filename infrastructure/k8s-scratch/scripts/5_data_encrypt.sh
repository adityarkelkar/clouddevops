#!/bin/bash
# Generating the Data Encryption Config and Key

# The Encryption Key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# The Encryption Config File
cat > cfg/encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for instance in controller-0 controller-1 controller-2; do
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ~/Downloads/dockerubuntu.pem cfg/encryption-config.yaml ubuntu@${external_ip}:~/
done

