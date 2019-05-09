# example.tf
provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "virtualprvatecloud" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	instance_tenancy = "default"
	tags = {
		Name = "private"
	}
}

resource "aws_instance" "instance" {
	ami = "ami-0a313d6098716f372"
	instance_type = "t2.micro"
	tags = {
		Name = "privatrec2"
	}
}

resource "aws_key_pair" "key" {
	key_name = "tfkey"
	public_key = "${file("~/.ssh/tfkey.pub")}"
}