variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

variable "vpc_tenancy" {
	default = "default"
}

variable "subnet1_cidr" {
	default = "10.0.0.0/24"
}

variable "subnet2_cidr" {
	default = "10.0.2.0/24"
}