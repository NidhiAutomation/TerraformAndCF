provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
  }

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "mysubnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "gw"
  }
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "myrt"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "inbound traffic"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_instance" "m1" {
  ami = "ami-04b70fa74e45c3917"
  security_groups = [aws_security_group.mySG.id]
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id
  key_name = "my-key"
  user_data = file("userdata1.sh")
  tags = {
    Name = "m1"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.m1.id
  domain   = "vpc"
}

resource "aws_instance" "m2" {
  ami = "ami-04b70fa74e45c3917"
  security_groups = [aws_security_group.mySG.id]
  associate_public_ip_address = true
  subnet_id     = aws_subnet.mysubnet.id
  instance_type = "t2.medium"
  key_name = "my-key"
  user_data = file("userdata1.sh")
  tags = {
    Name = "m2"
  }
}

resource "aws_instance" "m3" {
  ami = "ami-04b70fa74e45c3917"
  security_groups = [aws_security_group.mySG.id]
  subnet_id     = aws_subnet.mysubnet.id
  associate_public_ip_address = true
  instance_type = "t2.micro"
  key_name = "my-key"
  user_data = file("userdata2.sh")
  tags = {
    Name = "m3"
  }
}

resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tfkey" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkeys"
}










