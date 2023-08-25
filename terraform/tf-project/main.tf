# terraform init
# choose a provider and credentials (in UI, store them in env variables)
provider "aws" {
  region     = "us-east-1"
  access_key = "your_access_key"
  secret_key = "your_secret_key"
}


# create a vpc
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"

  tags ={
    Name = "production"
  }
}

# create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod-gateway"
  }
}

# create a custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"   #default route, send all ips where the route points
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-route"
  }
}

# create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block = var.subnet_prefix
  availability_zone = "us-east-1a"

  tags ={
    Name = "prod-subnet"
  }
}

# associate subnet with route table 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# create a security group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80 
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# create a network interface 
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# create an elastic IP  - depends on the creation of the gateaway
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

# output in the terminal after the applied changes
# output for server public ip
output "server_public_ip" {
  value = aws_eip.one.public_ip
}

#another output for instance id
output "instance_id" {
  value = aws_instance.web-server-instance.id
}

#another output for private ip
output "private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

# create an ubuntu server and install apache2 on it
resource "aws_instance" "web-server-instance" {
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "win-pair"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
                      # in user data you can input commands to execute 
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update - y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c "echo your very first web server > /var/www/html/index.html"
                EOF


  tags = {
    Name = "Ubuntu"
  } 
}