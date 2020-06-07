variable "region" {
  description = "AWS region for hosting our your network"
  default = "ap-south-1"
}
variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default = "/key/login.pem"
}
variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "login"
}
variable "ami" {
  description = "Base AMI to launch the instances"
  default = "ami-0b44050b2d893d5f7"
}

variable "inst_type" {
  default = "t2.micro"
  description = "AWS Instance type"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "VPC CIDR Block"
}

variable "public_subnet_1_cidr" {
  description = "Public subnet 1 cidr"
}

variable "public_subnet_2_cidr" {
  description = "Public subnet 2 cidr"
}

variable "public_subnet_3_cidr" {
  description = "Public subnet 3 cidr"
}

variable "private_subnet_1_cidr" {
  description = "private subnet 1 cidr"
}

variable "private_subnet_2_cidr" {
  description = "private subnet 2 cidr"
}

variable "private_subnet_3_cidr" {
  description = "private subnet 3 cidr"
}
