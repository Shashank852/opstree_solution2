# output "instance_ids" {
#     value = aws_instance.web.0.public_ip
# }
output "elb_dns_name" {
  value = aws_elb.app_elb.dns_name
}
output "vpc_id" {
  value = aws_vpc.production-vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.production-vpc.cidr_block
}

output "public_subnet_1_id" {
  value = aws_subnet.public-subnet-1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public-subnet-2.id
}

output "public_subnet_3_id" {
  value = aws_subnet.public-subnet-3.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private-subnet-1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private-subnet-2.id
}
output "private_subnet_3_id" {
  value = aws_subnet.private-subnet-3.id
}

output "private_subnets" {
  value = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id,
    aws_subnet.private-subnet-3.id,
  ]
}

output "public_subnets" {
  value = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id,
    aws_subnet.public-subnet-3.id,
  ]
}