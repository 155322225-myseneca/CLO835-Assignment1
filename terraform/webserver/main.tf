#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "tf_remote_state_dev" {
  backend = "s3"
  config = {
    bucket = "clo835-fall2024-assignment1"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Create EC2 instance Linux_VM 
resource "aws_instance" "Linux_VM" {
  #count                       = length(data.terraform_remote_state.tf_remote_state_dev.outputs.private_subnet_ids)
  ami                         = data.aws_ami.latest_amazon_linux.id
  #instance_type               = lookup(var.instance_type, var.env)
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.tf_remote_state_dev.outputs.public_subnet_id[0]
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"
  user_data                   = <<EOF
                             #!/bin/bash
                            sudo yum update -y
                            sudo yum install docker -y
                            sudo systemctl start docker
                            sudo systemctl enable docker
                            sudo usermod -a -G docker ec2-user
                            EOF
  tags = {
    Name = "VM0"
  }
}

resource "aws_ecr_repository" "my_appdb" {
  name                 = "ecr_my_db"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "my_app" {
  name                 = "ecr_my_app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = "dev"
  public_key = file("dev.pub")
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh_dev"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.tf_remote_state_dev.outputs.vpc_id
  
  ingress {
    description      = "HTTP from Everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from Everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
    ingress {
    description      = "Ports of Container"
    from_port        = 8081
    to_port          = 8083
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
      Name = "web-sg"
    }
}
