### Create a networking stack using boto3

#### Resources to be created
1. VPC
2. Internet Gateway
3. Subnets (1 public and 1 private)
4. Route table

#### To Create resources
1. Run the `networking.py` script. Pass the VPC name as command line argument. Eg
```
python networking.py PrepVPC
```

#### Cleaning up
1. Run the `teardown.py` script. Pass the name of the VPC you want to clean up as a  command line argument. Eg
```
python teardown.py PrepVPC
```
