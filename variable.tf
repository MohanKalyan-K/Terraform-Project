variable "vpc" {
	description = "My own vpc"
	type = string
	default = "10.0.0.0/16"
}

variable "sub_pub1" {
	description = "My public subnet 1"
        type = string
	default = "10.0.1.0/24"
}

variable "sub_pub2" {
	description = "My public subnet 2"
        type = string
	default = "10.0.2.0/24"
}

variable "sub_priv" {
	description = "My private subnet"
        type = string
	default = "10.0.3.0/24"
}

variable "ami_id" {
	description = "ami id for ec2_instance"
 	type = string
	default = "ami-0182f373e66f89c85"
}

variable "instance_type" {
	description = "instance type of ec2_instance"
	type = string
	default = "t2.micro"
}
