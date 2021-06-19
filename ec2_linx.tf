
variable public_key_location {}

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
}