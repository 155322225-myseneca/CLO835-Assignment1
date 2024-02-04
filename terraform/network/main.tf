# Define the provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "main" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "public_subnet" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet"
  }
}
