##https://medium.com/analytics-vidhya/terraform-diagrams-provisioning-and-visualizing-a-simple-environment-on-aws-471f5d88c95d

### VPC SECTION
## VPC for APP
resource "aws_vpc" "dac_app_vpc" {
  cidr_block           = "10.128.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
tags = {
    Name = "dac_app_vpc"
  }
}
## VPC for DB
resource "aws_vpc" "dac_db_vpc" {
  cidr_block           = "10.240.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "dac_db_vpc"
  }
}
### SUBNET SECTION
## Subnet for APP
resource "aws_subnet" "dac_app_subnet" {
  vpc_id            = aws_vpc.dac_app_vpc.id
  cidr_block        = "10.128.0.0/24"
  availability_zone = "sa-east-1a"
tags = {
    Name = "dac_app_subnet"
  }
}
## Subnet for DB
resource "aws_subnet" "dac_db_subnet_1" {
  vpc_id            = aws_vpc.dac_db_vpc.id
  cidr_block        = "10.240.0.0/24"
  availability_zone = "sa-east-1b"
tags = {
    Name = "dac_db_subnet_1"
  }
}
resource "aws_subnet" "dac_db_subnet_2" {
  vpc_id            = aws_vpc.dac_db_vpc.id
  cidr_block        = "10.240.1.0/24"
  availability_zone = "sa-east-1c"
tags = {
    Name = "dac_db_subnet_2"
  }
}
### INTERNET GW SECTION
## Internet Gateway for APP
resource "aws_internet_gateway" "dac_app_igw" {
  vpc_id = aws_vpc.dac_app_vpc.id
tags = {
    Name = "dac_app_igw"
  }
}
### VPC PEERING SECTION
## Peering connection between dac_app_vpc and dac_db_vpc
resource "aws_vpc_peering_connection" "dac_app_db_peering" {
  peer_vpc_id   = aws_vpc.dac_db_vpc.id
  vpc_id        = aws_vpc.dac_app_vpc.id
  auto_accept   = true
tags = {
    Name = "dac_vpc_app_db_peering"
  }
}
### ROUTE TABLE SECTION
## Route for APP
resource "aws_route_table" "dac_app_rt" {
  vpc_id = aws_vpc.dac_app_vpc.id
route {
    cidr_block                = "10.240.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.dac_app_db_peering.id
  }
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dac_app_igw.id
  }
tags = {
    Name = "dac_app_rt"
  }
}
## Route for DB
resource "aws_route_table" "dac_db_rt" {
  vpc_id = aws_vpc.dac_db_vpc.id
route {
    cidr_block                = "10.128.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.dac_app_db_peering.id
  }
tags = {
    Name = "dac_db_rt"
  }
}
## Route Table - Subnet Associations
resource "aws_route_table_association" "dac_app_rta2" {
  subnet_id      = aws_subnet.dac_app_subnet.id
  route_table_id = aws_route_table.dac_app_rt.id
}
resource "aws_route_table_association" "dac_db_rta1" {
  subnet_id      = aws_subnet.dac_db_subnet_1.id
  route_table_id = aws_route_table.dac_db_rt.id
}
resource "aws_route_table_association" "dac_db_rta2" {
  subnet_id      = aws_subnet.dac_db_subnet_2.id
  route_table_id = aws_route_table.dac_db_rt.id
}
### SECURITY GROUPS SECTION
## SG for APP VPC
resource "aws_security_group" "dac_app_sg" {
  name = "dac_app_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.dac_app_vpc.id
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH from my Public IP"
    cidr_blocks = ["<public_IP>/32"]
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
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "dac_app_sg"
  }
}
## SG for DB VPC
resource "aws_security_group" "dac_db_sg" {
  name = "dac_db_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.dac_db_vpc.id
ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Allow traffic to MySQL"
    cidr_blocks = ["10.128.0.0/24"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "dac_db_sg"
  }
}
Summary of main resources created by the previous “.tf” file:
dac_app_vpc: VPC for APP (CIDR: 10.128.0.0/16)
dac_db_vpc: VPC for DB (CIDR: 10.240.0.0/16)
dac_app_subnet: Subnet for APP (CIDR: 10.128.0.0/24)
dac_db_subnet_1: Subnet 1 for DB (CIDR: 10.240.0.0/24)
dac_db_subnet_2: Subnet 2 for DB (CIDR: 10.240.1.0/24)
dac_app_igw: Allow the traffic from APP to Internet
dac_vpc_app_db_peering: Allow the communication between VPCs
dac_app_rt: Route table for APP
dac_db_rt: Route table for DB
dac_app_sg: Security group for APP VPC (Ingress: allow ports 22, 80 and 443. Egress: All networks)
dac_db_sg: Security group for DB VPC (Ingress: allow only port 3306 from APP Subnet. Egress: All networks)


## EC2 INSTANCES
resource "aws_instance" "dac_app" {
  count                         = 3
  ami                           = "ami-02898a1921d38a50b"
  instance_type                 = "t2.micro"
  key_name                      = "<KEY_name>"
  vpc_security_group_ids        = [aws_security_group.dac_app_sg.id]
  subnet_id                     = aws_subnet.dac_app_subnet.id
  associate_public_ip_address   = "true"
tags = {
    Name = "dac_app_${count.index}"
  }
}
## NLB
resource "aws_lb" "dac_app_lb" {
  name               = "dac-app-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.dac_app_subnet.*.id
tags = {
    Environment = "dev"
  }
}
## LB Target Group
resource "aws_lb_target_group" "dac_app_tgp" {
  name     = "dac-app-tgp"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.dac_app_vpc.id
}
## LB Targets Registration
resource "aws_lb_target_group_attachment" "dac_app_tgpa" {
  count            = length(aws_instance.dac_app)
  target_group_arn = aws_lb_target_group.dac_app_tgp.arn
  target_id        = aws_instance.dac_app[count.index].id
  port             = 80
}
## LB Listener
resource "aws_lb_listener" "dac_app_lb_listener" {
  load_balancer_arn = aws_lb.dac_app_lb.arn
  port              = "80"
  protocol          = "TCP"
default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dac_app_tgp.arn
  }
}

Summary of main resources created by the previous “.tf” file:
dac_app: Three EC2 Instances (dac_app_0, dac_app_1 and dac_app_2)
dac_app_lb: External Network Load Balancer
dac_app_tgp: Target group to receive traffic from NLB
dac_app_tgpa: Group Instances attached on dac_app_tgp
dac_app_lb_listener: LB listener on port 80 (HTTP)