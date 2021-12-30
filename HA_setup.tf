resource "aws_vpc" "demo-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_subnet" "pub-1a" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pub-1a"
  }
}

resource "aws_subnet" "pub-1b" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "pub-1b"
  }
}

resource "aws_subnet" "priv-1a" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "priv-1a"
  }
}

resource "aws_subnet" "priv-1b" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "priv-1b"
  }
}

resource "aws_route_table" "route-pub" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "route-pub"
  }
}

resource "aws_route_table_association" "route-1a" {
  subnet_id      = aws_subnet.pub-1a.id
  route_table_id = aws_route_table.route-pub.id
}

resource "aws_route_table_association" "route-1b" {
  subnet_id      = aws_subnet.pub-1b.id
  route_table_id = aws_route_table.route-pub.id
}

resource "aws_eip" "eip-1" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-pub-1a" {
  allocation_id = aws_eip.eip-1.id
  subnet_id     = aws_subnet.pub-1a.id

  tags = {
    Name = "nat-pub-1A"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my-igw]
}

resource "aws_eip" "eip-2" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-pub-2a" {
  allocation_id = aws_eip.eip-2.id
  subnet_id     = aws_subnet.pub-1b.id

  tags = {
    Name = "nat-pub-1b"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my-igw]
}
resource "aws_route_table" "route-priv" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-pub-1a.id
  }

  tags = {
    Name = "route-priv"
  }
}
resource "aws_route_table" "route-privb" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-pub-2a.id
  }

  tags = {
    Name = "route-privb"
  }
}
resource "aws_route_table_association" "route-priv-1a" {
  subnet_id      = aws_subnet.priv-1a.id
  route_table_id = aws_route_table.route-priv.id
}
resource "aws_route_table_association" "route-priv-1b" {
  subnet_id      = aws_subnet.priv-1b.id
  route_table_id = aws_route_table.route-privb.id
}

