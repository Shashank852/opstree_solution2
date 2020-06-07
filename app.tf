provider "aws" {
  region     = "ap-south-1"
}

terraform {
    backend "s3"{}
}

# data "aws_availability_zones" "all" {}
### Creating EC2 instance
# resource "aws_instance" "web" {
#   ami                    = var.ami
#   count                  = var.count
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.instance.id]
#   source_dest_check = false
#   instance_type = var.inst_type
# tags {
#     Name = "${format("web-%03d", count.index + 1)}"
#   }
# }
### Creating Security Group for EC2

data "template_file" "user_data" {
  template = file("user_data.sh")
}

## Creating Launch Configuration
resource "aws_launch_configuration" "app_launch_conf" {
  name                   = "terraform-app-launch-conf"
  image_id               = var.ami
  instance_type          = var.inst_type
  security_groups        = [aws_security_group.asg.id]
  key_name               = var.key_name
  user_data              = data.template_file.user_data.rendered
  iam_instance_profile   = "arn:aws:iam::159038142581:instance-profile/layer-ec2-s3-admin"
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               sudo apt-get update
#               sudo apt install default-jre
#               sudo apt install maven
#               sudo apt-get update
#               sudo apt-get install mysql-server
#               systemctl start mysql
#               systemctl enable mysql
#               sudo apt-get update
#               aws s3 cp s3://spring-application-code/ . --recursive
#               mvn clean package > output.txt
#               EOF
  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "application" {
  name                 = "terraform-app-asg"
  launch_configuration = aws_launch_configuration.app_launch_conf.name
  availability_zones = ["ap-south-1a","ap-south-1b","ap-south-1c"] #data.aws_availability_zones.all.names
  min_size = 1
  desired_capacity = 1
  max_size = 2
  #volume_size = 40
  load_balancers = [aws_elb.app_elb.name]
  health_check_type = "ELB"
  vpc_zone_identifier = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id, aws_subnet.public-subnet-3.id]
  tag {
    key = "Name"
    value = "terraform-asg-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "autopolicy" {
name = "application-autoplicy"
scaling_adjustment = 1
adjustment_type = "ChangeInCapacity"
cooldown = 300
autoscaling_group_name = aws_autoscaling_group.application.name
}

## Security Group for ASG
resource "aws_security_group" "asg" {
  name = "terraform-application-instance"
  vpc_id = aws_vpc.production-vpc.id
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-application-elb"
  vpc_id = aws_vpc.production-vpc.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
### Creating ELB
resource "aws_elb" "app_elb" {
  name = "terraform-asg-example"
  security_groups = [aws_security_group.elb.id]
#   availability_zones = ["ap-south-1a","ap-south-1b","ap-south-1c"]
  subnets = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id,
    aws_subnet.public-subnet-3.id,
  ]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300
}

resource "aws_lb_cookie_stickiness_policy" "cookie_stickness" {
name = "cookiestickness"
load_balancer = aws_elb.app_elb.id
lb_port = 80
cookie_expiration_period = 600
}