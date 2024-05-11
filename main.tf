provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_vpc" "fis_vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.10.1.0/24"
  vpc_id     = aws_vpc.fis_vpc.id
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.10.2.0/24"
  vpc_id     = aws_vpc.fis_vpc.id
}

resource "aws_internet_gateway" "fis_public_internet_gateway" {
  vpc_id = aws_vpc.fis_vpc.id
}

resource "aws_route_table" "fis_public_subnet_route_table" {
  vpc_id = aws_vpc.fis_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fis_public_internet_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.fis_public_internet_gateway.id
  }
}

resource "aws_route_table_association" "fis_public_association" {
  route_table_id = aws_route_table.fis_public_subnet_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_security_group" "web_server_sg" {
  vpc_id = aws_vpc.fis_vpc.id

  ingress {
    description = "Allow HTTP inbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS inbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "aeis security group"
  }
}

# Datablock: Se utiliza para definir información específica que es extensa

data "aws_ami" "ubuntu" {
  most_recent = "true"
  filter {
    name   = "OS Name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "fis_ubuntu_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

}
