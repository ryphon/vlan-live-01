resource "aws_vpc" "main" {
	cidr_block = var.vpc_cidr_block
	tags = merge({Name = var.vpc_name}, var.tags)
}

resource "aws_internet_gateway" main {
	count = var.internet ? 1 : 0
	vpc_id = aws_vpc.main.id
	tags = merge({Name = var.vpc_name}, var.tags)
}

resource "aws_route_table" main {
	count = var.internet ? 1 : 0
	vpc_id = aws_vpc.main.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.main[0].id
	}
}

resource "aws_subnet" "main" {
	count = var.subnet_count
	vpc_id = aws_vpc.main.id
	cidr_block = cidrsubnet(var.vpc_cidr_block, var.subnet_size, count.index)
	availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
	tags = merge({Name = "${var.vpc_name}-subnet-${count.index}"}, var.tags)
}

resource "aws_route_table_association" "main" {
	count = var.internet ? var.subnet_count : 0
	subnet_id = aws_subnet.main[count.index].id
	route_table_id = aws_route_table.main[0].id
}

data "aws_availability_zones" "available" {
	state = "available"
}

resource "aws_network_acl" "main" {
	vpc_id = aws_vpc.main.id
	subnet_ids = aws_subnet.main[*].id
	tags = merge({Name = var.vpc_name}, var.tags)
}

resource "aws_network_acl_rule" "ssh_in" {
	count = var.ssh ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 229
	egress = false
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 22
	to_port = 22
}

resource "aws_network_acl_rule" "ssh_out" {
	count = var.ssh ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 228
	egress = true
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 22
	to_port = 22
}

resource "aws_network_acl_rule" "http_in" {
	count = var.http ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 809
	egress = false
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 80
	to_port = 80
}

resource "aws_network_acl_rule" "http_out" {
	count = var.http ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 808
	egress = true
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 80
	to_port = 80
}

resource "aws_network_acl_rule" "https_in" {
	count = var.https ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 4439
	egress = false
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 443
	to_port = 443
}

resource "aws_network_acl_rule" "https_out" {
	count = var.https ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 4438
	egress = true
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 443
	to_port = 443
}

resource "aws_network_acl_rule" "ephemeral_in" {
	count = var.ephemeral ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 10259
	egress = false
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 1025
	to_port = 65535
}

resource "aws_network_acl_rule" "ephemeral_out" {
	count = var.ephemeral ? 1 : 0
	network_acl_id = aws_network_acl.main.id
	rule_number = 10258
	egress = true
	protocol = "tcp"
	cidr_block = "0.0.0.0/0"
	rule_action = "allow"
	from_port = 1025
	to_port = 65535
}
