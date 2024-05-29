output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "subnets_ids" {
  value = aws_subnet.subnets[*].id
}
