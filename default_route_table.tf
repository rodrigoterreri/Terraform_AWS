### Using DEFAULT ROUTE TABLE
## Route for DEV
resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.dev.default_route_table_id
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags       = {
  Name       = "dev_rt_az_1a"
  }
}

## Route Table - Subnet Associations
resource "aws_route_table_association" "route_association_az_1a" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_default_route_table.main_rtb.id
}

resource "aws_route_table_association" "route_association_az_1b" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_default_route_table.main_rtb.id
}

######################################################################

### Creating a new ROUTE TABLE
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