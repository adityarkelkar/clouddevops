import boto3
import sys
import os

def main():
    ec2 = boto3.resource('ec2')
    args = sys.argv
    try:
        vpcname = args[1]
        vpc = createVPC(ec2, vpcname)
        ig = createIG(ec2, vpc)
        public_subnet = createSubnet(ec2, vpc, 'public')
        private_subnet = createSubnet(ec2, vpc, 'private')
        route_table = createRouteTable(vpc, ig, public_subnet)
    except IndexError:
        print("Please specify the VPC name! Usage: " + os.path.basename(__file__) + " <arg1>")
        sys.exit(1)

'''
@function createVPC - Create a new Virtual Private Gateway in your AWS account
@param ec2 - Boto3 library recourse for AWS ec2
@param vpcname - String value passed as command line argument
@return vpc - The VPC object created by function
'''
def createVPC(ec2, vpcname):
    vpc = ec2.create_vpc('PrepVPC', CidrBlock='10.0.0.0/16')
    vpc.wait_until_available()
    vpc.create_tags(Tags=[{"Key": "Name", "Value": vpcname}])
    print(f'VPC: {vpc.id}')
    return vpc

'''
@function createIG - Create Internet Gateway and attach to VPC
@param ec2 - Boto3 library recourse for AWS ec2
@param vpc - VPC object created from the earlier function
@return ig - Internet gateway object created by function
'''
def createIG(ec2, vpc):
    ig = ec2.create_internet_gateway()
    ig.create_tags(Tags=[{"Key" : "Name", "Value" : "PrepIG"}])
    vpc.attach_internet_gateway(InternetGatewayId=ig.id)
    print(f'Internet Gateway: {ig.id}')
    return ig

'''
@function createSubnet - Create a public and/or private subnet
@param ec2 - Boto3 library recourse for AWS ec2
@param vpc - VPC object created from the earlier function
@param type - String value of the type of subnet to be created
@return public_subnet/provate_subnet - Subnet object
'''
def createSubnet(ec2, vpc, type):
    if type == 'public':
        public_subnet = ec2.create_subnet(CidrBlock='10.0.1.0/24', VpcId=vpc.id, AvailabilityZone='us-east-1c')
        public_subnet.create_tags(Tags=[{"Key" : "Name", "Value" : "PublicSubnet"}])
        print(f'Public Subnet: {public_subnet.id}')
        return public_subnet
    elif type == 'private':
        private_subnet = ec2.create_subnet(CidrBlock='10.0.2.0/24', VpcId=vpc.id, AvailabilityZone='us-east-1d')
        private_subnet.create_tags(Tags=[{"Key" : "Name", "Value" : "PrivateSubnet"}])
        print(f'Private Subnet: {private_subnet.id}')
        return private_subnet

'''
@function createRouteTable - Create a public route table and a route out to internet. Associate public subnet
@param vpc - VPC object created from the earlier function
@param ig - Internet gateway object created from the earlier function
@param public_subnet - Public subnet object created from earlier function
@return route - Route table object
'''
def createRouteTable(vpc, ig, public_subnet):
    route_table = vpc.create_route_table()
    route_table.create_tags(Tags=[{"Key" : "Name", "Value" : "PublicRouteTable"}])
    route = route_table.create_route(DestinationCidrBlock='0.0.0.0/0', GatewayId=ig.id)
    route_table.associate_with_subnet(SubnetId=public_subnet.id)
    print(f'Public route table: {route_table.id}')
    return route


if __name__ == "__main__":
    main()