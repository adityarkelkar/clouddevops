import boto3
import sys
import os

def main():
    ec2 = boto3.resource('ec2')
    client = ec2.meta.client
    args = sys.argv
    createInstance(ec2, 'ec2-keypair-boto')
    try:
        vpcname = args[1]
        filters = [{'Name':'tag:Name', 'Values':[vpcname]}]
        vpcs = list(ec2.vpcs.filter(Filters=filters))
        vpc = vpcs[0]
        keypair = createKeyPair(ec2)
        security_group = createSecurityGroup(ec2, vpc)
    except IndexError:
        print("Please specify the VPC name! Usage: " + os.path.basename(__file__) + " <arg1>")
        sys.exit(1)

def createKeyPair(ec2):
    keyname='ec2-keypair-boto'
    outfile = open('ec2-keypair-boto.pem','w')
    key_pair = ec2.create_key_pair(KeyName=keyname)
    KeyPairOut = str(key_pair.key_material)
    outfile.write(KeyPairOut)
    return keyname

def createSecurityGroup(ec2, vpc):
    sec_group=ec2.create_security_group (
        GroupName='BotoWebSecurityGroup',
        Description='Sample web security group created with Boto',
        VpcId=vpc
    )
    sec_group.authorize_ingress( CidrIp='0.0.0.0/0', IpProtocol='http', FromPort=80, ToPort=80 )
    sec_group.authorize_ingress( CidrIp='0.0.0.0/0', IpProtocol='ssh', FromPort=22, ToPort=22 )


def createInstance(ec2, keypair, subnetid):
    instance = ec2.create_instances(
        ImageId='ami-07d0cf3af28718ef8',
        MinCount=1,
        MaxCount=1,
        InstanceType='t2.micro',
        KeyName=keypair,
        NetworkInterfaces=[{
            'AssociatePublicIpAddress': True,
            'SubnetId': subnetid
        }]
    )

if __name__ == "__main__":
    main()