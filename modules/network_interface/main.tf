variable "subnet_id" {
  
}

variable "web_server_sg_id" {
  
}

resource "aws_network_interface" "aeis_network_interface" {
  subnet_id       = var.subnet_id
  private_ips     = ["10.0.1.24"] // Private IP address for the network interface
  security_groups = [var.web_server_sg_id]
}

output "aeis_network_interface_id" {
  value = aws_network_interface.aeis_network_interface.id
}

output "aeis_network_interface_private_ips" {
  value = aws_network_interface.aeis_network_interface.private_ips
}