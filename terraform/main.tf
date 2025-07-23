provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "DevOps-VPC"
  }
}

resource "aws_subnet" "devops_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "DevOps-Subnet"
  }
}

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "DevOps-IGW"
  }
}

resource "aws_route_table" "devops_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "DevOps-RouteTable"
  }
}

resource "aws_route_table_association" "devops_rta" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.devops_rt.id
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Allow SSH, HTTP, and Prometheus/Grafana"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-SG"
  }
}

resource "aws_instance" "devops_instance" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.devops_subnet.id
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "DevOps-Server"
  }
}
