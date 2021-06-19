resource "aws_instance" "server_windows_az_1a" {
ami                         = "ami-0be6f09264f372d7a"
instance_type               = var.instance_type

subnet_id                   = aws_subnet.subnet_public_1a.id
vpc_security_group_ids      = [aws_security_group.dev_sg.id]
availability_zone           = "us-east-1a"

associate_public_ip_address = true
key_name                    = "aws_key_pair"

tags                        = {
Name                        = "server_windows_az_1a_${var.env_prefix}"
}
}

output "server_windows_az_1a" {
value = aws_instance.server_windows_az_1a.public_ip
}
