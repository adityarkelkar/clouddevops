import boto3

ec2 = boto3.resource('ec2')
client = ec2.meta.client

filters = [{'Name':'tag:Name', 'Values':['PrepVPC']}]
vpcs = list(ec2.vpcs.filter(Filters=filters))
vpc = vpcs[0]
# print(vpcs[0].id)

for gw in vpc.internet_gateways.all():
    vpc.detach_internet_gateway(InternetGatewayId=gw.id)
    gw.delete()
print("Internet gateway detached and deleted")
client.delete_vpc(VpcId=vpc.id)
print("VPC deleted")