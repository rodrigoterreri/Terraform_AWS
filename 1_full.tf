provider "aws" {
  region     = "us-east-1"
}

## teste 

variable subnet_dev_1a {}
variable subnet_dev_1b {}
variable instance_type {}
variable public_key_location {}
variable env_prefix {}

### VPC SECTION
## VPC for DEV

resource "aws_vpc" "dev" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc-dev"
  }
}

### SUBNET SECTION
## Subnet for DEV-AZ-1A
# map_public_ip_on_launch = true

resource "aws_subnet" "subnet_public_1a" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet_dev_1a

  availability_zone       = "us-east-1a"
    tags = {
    Name = "subnet_public_1a"
    }
}

## Subnet for DEV-AZ-1B
resource "aws_subnet" "subnet_public_1b" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet_dev_1b
  availability_zone       = "us-east-1b"
    tags = {
    Name = "subnet_public_1b"
    }
}

### INTERNET GW SECTION
## Internet Gateway for DEV
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev.id
tags = {
    Name = "dev_igw"
  }
}

### ROUTE TABLE SECTION
## Route for DEV
resource "aws_route_table" "dev_rt_az_1a" {
  vpc_id     = aws_vpc.dev.id
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags       = {
  Name       = "dev_rt_az_1a"
  }
}

resource "aws_route_table" "dev_rt_az_1b" {
  vpc_id     = aws_vpc.dev.id
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags       = {
  Name       = "dev_rt_az_1b"
  }
}

## Route Table - Subnet Associations
resource "aws_route_table_association" "route_association_az_1a" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.dev_rt_az_1a.id
}

resource "aws_route_table_association" "route_association_az_1b" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.dev_rt_az_1b.id
}

### SECURITY GROUPS SECTION
## SG for DEV VPC
resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.dev.id
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description = "Allow SSH from my Public IP"
  cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  description = "Allow HTTP traffic"
  cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "Allow HTTPS traffic"
  cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  description = "ICMP"
  cidr_blocks = ["0.0.0.0/0"]
  }
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags        = {
  Name        = "dev_sg"
  }
}

## FILTERING LAST VERSION OF LINUX AMI - FREE
data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_key_pair" "ssh_key" {
    key_name = "server_key"
    public_key = file(var.public_key_location)
}

## DEPLOY EC2 INSTANCES
resource "aws_instance" "server_az_1a" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.subnet_public_1a.id
    vpc_security_group_ids = [aws_security_group.dev_sg.id]
    availability_zone = "us-east-1a"

    associate_public_ip_address = true
    #key_name = "aws_key_pair"
    key_name = "server_key"

    tags = {
        Name = "server_az_1a_${var.env_prefix}"
    }

    user_data = <<EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl enable httpd.service
              systemctl start httpd.service
              echo "<html><h1>Web Server #1</h1></html>" > /var/www/html/index.html
            EOF
        }

resource "aws_instance" "server_az_1b" {
    ami                         = data.aws_ami.latest-amazon-linux-image.id
    instance_type               = var.instance_type

    subnet_id                   = aws_subnet.subnet_public_1b.id
    vpc_security_group_ids      = [aws_security_group.dev_sg.id]
    availability_zone           = "us-east-1b"

    associate_public_ip_address = true
    #key_name = "aws_key_pair"
    key_name = "server_key"

    tags = {
        Name = "server_az_1b_${var.env_prefix}"
    }

    user_data = <<EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl enable httpd.service
              systemctl start httpd.service
              echo "<html><h1>Web Server #2</h1></html>" > /var/www/html/index.html
            EOF
        }

## OUTPUTS
output "aws_ami_id_1a" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "aws_ami_id_1b" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "public_ip_ec2_az_1a" {
    value = aws_instance.server_az_1a.public_ip
}

output "public_ip_ec2_az_1b" {
    value = aws_instance.server_az_1b.public_ip
}