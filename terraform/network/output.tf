# Add output variables
output "public_subnet_id" {
  value = aws_default_subnet.public_subnet[*].id
}

output "vpc_id" {
  value = aws_default_vpc.main.id
}
