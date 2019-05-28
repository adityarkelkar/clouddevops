provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.vpc_tenancy}"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet1_cidr}"

  tags = {
    Name = "Subnet1"
  }
}


resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet2_cidr}"

  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "ig"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags = {
    Name = "main"
  }
}

output "vpc_id" {
	value = "${aws_vpc.main.id}"
}

output "subnet1" {
	value = "${aws_subnet.subnet1.id}"
}

output "subnet2" {
	value = "${aws_subnet.subnet2.id}"
}

output "internet_gateway" {
	value = "${aws_internet_gateway.ig.id}"
}