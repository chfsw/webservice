#define a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}
#Define two subnets in different availability zones
resource "aws_subnet" "my_subnetA" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "my_subnetA"
  }
}
resource "aws_subnet" "my_subnetB" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnetB"
  }
}

#define an internet gateway
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_gateway"
  }
}
#define a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }

  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnetA.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "my_route_table_associationB" {
  subnet_id      = aws_subnet.my_subnetB.id
  route_table_id = aws_route_table.my_route_table.id
}
#define a security group for EC2 instance
resource "aws_security_group" "sg_instance" {
  name        = "sg_instance"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "sg_instance"
  }
}
#Define ingress for HTTPS and SSH
resource "aws_vpc_security_group_ingress_rule" "allow_ec2_ssl_ingress" {
  security_group_id = aws_security_group.sg_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress" {
  security_group_id = aws_security_group.sg_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
# Define egress for EC2 instance
resource "aws_vpc_security_group_egress_rule" "instance_traffic_egress" {
  security_group_id = aws_security_group.sg_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp" 
  to_port           = 443
}

#Define a key pair for Ansible access to EC2 instances
resource "aws_key_pair" "my_key" {
  key_name  = "my_key"
  public_key = file("id_rsa.pub")
}
#define EC2 instanceA
resource "aws_instance" "my_instanceA" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnetA.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg_instance.id]
  key_name = aws_key_pair.my_key.key_name

  tags = {
    Name = "my_instanceA"
  }
}
# define EC2 instanceB
resource "aws_instance" "my_instanceB" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnetB.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg_instance.id]
  key_name = aws_key_pair.my_key.key_name

  tags = {
    Name = "my_instanceB"
  }
}
