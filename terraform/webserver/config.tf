terraform {
  backend "s3" {
    bucket = "clo835-fall2024-assignment1"
    key    = "dev/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}
