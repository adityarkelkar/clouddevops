availabilityZone="us-east-1a"
read -p "Enter your STACK_NAME to delete " name
stackName="$name-csye6225-vpc"
gatewayName="$name-csye6225-InternetGateway"
routeTableName="$name-csye6225-public-route-table"
vpcCidrBlock="10.0.0.0/16"

aws cloudformation delete-stack --stack-name $stackName
printf "\n\n"
printf "######################  DELETING THE STACK.... PATIENCE.....  ###################### \n"
printf "\n"
aws cloudformation wait stack-delete-complete --stack-name $stackName

printf "\n\n"

if [ $? -eq 0 ]; then
    printf "######################  Stack Deleted Successfully!!  ######################"
else
	printf "Stack Deletion Failed "
fi
printf "\n"
