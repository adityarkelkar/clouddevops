#!/bin/bash

LOAD_BALANCER_ARN=arn:aws:elasticloadbalancing:us-east-1:503673903511:loadbalancer/net/kubernetes/fd9cac648587e70e
TARGET_GROUP_ARN=arn:aws:elasticloadbalancing:us-east-1:503673903511:targetgroup/kubernetes/8eb4d3a39ade02e7
SECURITY_GROUP_ID=sg-08d87aa6bc8f59733
ROUTE_TABLE_ID=rtb-040de4978c7f367e2
ROUTE_TABLE_ASSOCIATION_ID=rtbassoc-0d75d186fee9a791d
INTERNET_GATEWAY_ID=igw-030227e4771b6a577
SUBNET_ID=subnet-0d18eaf9671199933
DHCP_OPTION_SET_ID=dopt-083b89650133a80dd
VPC_ID=vpc-0e38e9ab995034079

aws ec2 terminate-instances \
  --instance-ids \
    $(aws ec2 describe-instances \
      --filter "Name=tag:Name,Values=controller-0,controller-1,controller-2,worker-0,worker-1,worker-2" \
      --output text --query 'Reservations[].Instances[].InstanceId')

aws elbv2 delete-load-balancer --load-balancer-arn "${LOAD_BALANCER_ARN}"
aws elbv2 delete-target-group --target-group-arn "${TARGET_GROUP_ARN}"
aws ec2 delete-security-group --group-id "${SECURITY_GROUP_ID}"
ROUTE_TABLE_ASSOCIATION_ID="$(aws ec2 describe-route-tables --route-table-ids "${ROUTE_TABLE_ID}" \
  --output text --query 'RouteTables[].Associations[].RouteTableAssociationId')"
aws ec2 disassociate-route-table --association-id "${ROUTE_TABLE_ASSOCIATION_ID}"
aws ec2 delete-route-table --route-table-id "${ROUTE_TABLE_ID}"
aws ec2 detach-internet-gateway --internet-gateway-id "${INTERNET_GATEWAY_ID}" --vpc-id "${VPC_ID}"
aws ec2 delete-internet-gateway --internet-gateway-id "${INTERNET_GATEWAY_ID}"
aws ec2 delete-subnet --subnet-id "${SUBNET_ID}"
aws ec2 delete-dhcp-options --dhcp-options-id "${DHCP_OPTION_SET_ID}"
aws ec2 delete-vpc --vpc-id "${VPC_ID}"



