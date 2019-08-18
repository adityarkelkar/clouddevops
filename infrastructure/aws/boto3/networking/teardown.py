import boto3
import sys
import os

ec2 = boto3.resource('ec2')
client = ec2.meta.client
args = sys.argv
try:
    vpcname = args[1]
except IndexError:
    print("Please specify the VPC name! Usage: " + os.path.basename(__file__) + " <arg1>")
    sys.exit(1)


filters = [{'Name':'tag:Name', 'Values':[vpcname]}]
vpcs = list(ec2.vpcs.filter(Filters=filters))
vpc = vpcs[0]

# Delete route associations table
for rt in vpc.route_tables.all():
    for rta in rt.associations:
        if not rta.main:
            rta.delete()
            rt.delete()
print('Route table associations deleted')

# Delete Subnets
for subnet in vpc.subnets.all():
    # Terminate instances in the subnets if present
    for instance in subnet.instances.all():
        instance.terminate()
    subnet.delete()
print('Subnets and related instances deleted')
    

# Delete internet gateway
for gw in vpc.internet_gateways.all():
    vpc.detach_internet_gateway(InternetGatewayId=gw.id)
    gw.delete()
print("Internet gateway detached and deleted")

# Delete VPC
client.delete_vpc(VpcId=vpc.id)
print("VPC deleted")