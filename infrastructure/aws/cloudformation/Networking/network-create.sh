availabilityZone="us-east-1a"
read -p "Enter your Network STACK_NAME: " name
stackName="$name-csye6225-vpc"

aws cloudformation create-stack --stack-name $stackName --template-body file://csye6225-cf-networking-stack.json --parameters ParameterKey=VPCName,ParameterValue=$stackName ParameterKey=PrivateRouteTableName,ParameterValue=$name-csye6225-private-route-table ParameterKey=PublicRouteTableName,ParameterValue=$name-csye6225-pubic-route-table ParameterKey=WebGroup,ParameterValue=csye6225-webapp ParameterKey=DBGroup,ParameterValue=csye6225-rds ParameterKey=LoadBalancerGroup,ParameterValue=csye6225-loadbalancer

# ParameterKey=EC2InstanceType,ParameterValue=t2.micro  "EC2InstanceType":{"Type":"String"}

printf "\n\n"
printf "Creating Stack and launching EC2 instance.... Please wait... \n"
printf "\n"
aws cloudformation wait stack-create-complete --stack-name $stackName

printf "\n\n"
if [ $? -eq 0 ]; then
    printf "Stack Created Successfully ...."
else
	printf "Stack Creation Failed "
fi
printf "\n"