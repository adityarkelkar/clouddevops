import boto3

ec2 = boto3.resource('ec2')

# Create VPC
vpc = ec2.create_vpc('PrepVPC', CidrBlock='10.0.0.0/16')
vpc.wait_until_available()
vpc.create_tags(Tags=[{"Key": "Name", "Value": "PrepVPC"}])
print(f'VPC: {vpc.id}')

# Create Internet Gateway and attach to VPC
ig = ec2.create_internet_gateway()
ig.create_tags(Tags=[{"Key" : "Name", "Value" : "PrepIG"}])
vpc.attach_internet_gateway(InternetGatewayId=ig.id)
print(f'Internet Gateway: {ig.id}')

# Create public subnet
public_subnet = ec2.create_subnet(CidrBlock='10.0.1.0/24', VpcId=vpc.id, AvailabilityZone='us-east-1c')
public_subnet.create_tags(Tags=[{"Key" : "Name", "Value" : "PublicSubnet"}])
print(f'Public Subnet: {public_subnet.id}')

# Create private subnet
private_subnet = ec2.create_subnet(CidrBlock='10.0.2.0/24', VpcId=vpc.id, AvailabilityZone='us-east-1d')
private_subnet.create_tags(Tags=[{"Key" : "Name", "Value" : "PrivateSubnet"}])
print(f'Private Subnet: {private_subnet.id}')