variable "aeis_network_interface_id" {
  
}

variable "aeis_network_interface_private_ips" {
  
}

//Data Block , Specific information for a resource
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] // Canonical
}

resource "aws_instance" "ubuntu_aeis_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = var.aeis_network_interface_id
    device_index         = 0 // Add to the actual device index
  }
  user_data = <<-EOF
              #!bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              EOF
  tags = {
    Name = "aeis ubuntu instance"
  }
}

resource "aws_eip" "aeis_ip" {
  associate_with_private_ip = tolist(var.aeis_network_interface_private_ips)[0]
  network_interface         = var.aeis_network_interface_id
  instance                  = aws_instance.ubuntu_aeis_instance.id
}

output "ubuntu_aeis_instance_id" {
  value = aws_instance.ubuntu_aeis_instance.id
}

output "public_aeis_ip" {
  value = aws_eip.aeis_ip.public_ip
}

output "private_aeis_ip" {
  value = aws_eip.aeis_ip.private_ip
}

