output "subnet_ids" {
	value = aws_subnet.main[*].id
}

output "vpc_id" {
	value = aws_vpc.main.id
}

output "vpc_arn" {
	value = aws_vpc.main.arn
}
