#provider "aws" {
# region = "us-east-1" # Choose the appropriate region
#}

resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.30.0/24" # Choose subnet from the drawing
  tags = {
    Name ="vpc-ceb03-${var.vpc-ceb03}"
    
  }
}

resource "aws_vpc" "my_vpc" {
cidr_block = "192.168.30.0/24"
tags = {
Name = "vpc-ceb03-${var.vpc-ceb03}"
Created_by = var.tag_createdby
}
}

resource "aws_vpc" "my_vpc" {
cidr_block = var.vpc_ciddr
tags = {
Name = "vpc-ceb03-${var.vpc-ceb03}"
Created_by = var.tag_createdby
}
}


resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.168.30.0/28" # Choose subnet from the drawing
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a" # Adjust based on your region
  tags = {
    Name = "pub-subnet01"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.168.30.16/28"
  availability_zone = "us-east-1a" # Adjust based on your region
  tags = {
    Name = "priv-subnet01"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "ceb-lorena-igw-gateway"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name = "ceb-lorena-nat-gateway" # From requirements
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = " ceb-lorena-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "ceb-lorena-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "allow_web" {

  name        = "allow_web_traffic"

  description = "Allow Web inbound traffic"

  vpc_id      = aws_vpc.my_vpc.id
 
  ingress {

    description      = "SSH from Anywhere"

    from_port        = 22

    to_port          = 22

    protocol         = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]

  }
 
  ingress {

    description      = "HTTP from Anywhere"

    from_port        = 80

    to_port          = 80

    protocol         = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]

  }
 
  egress {

    from_port        = 0

    to_port          = 0

    protocol         = "-1"

    cidr_blocks      = ["0.0.0.0/0"]

  }
 
  tags = {

    Name = "allow_web"

  }

}
 
resource "aws_key_pair" "deployer" {

  key_name   = "deployer-key"

  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUpl1WHILsmNKTet855Fm+N7P7D8seSK5b/Mk5oPh+A raul@raul-laptop"

}
 
 
resource "aws_instance" "web" {

  ami           = "ami-05785d30a1f964b76" # This is an Amazon Linux 2 AMI in us-east-1. Update it based on your region and desired AMI

  instance_type = "t3.nano"

  subnet_id     = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.allow_web.id]

  key_name      = aws_key_pair.deployer.key_name
 
  tags = {

    Name = "MyWebServer"
    

  }

}
