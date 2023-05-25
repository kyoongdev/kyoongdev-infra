resource "aws_vpc" "default_vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.namespace}_vpc_${var.env}"
  }
}
resource "aws_subnet" "public_subnet" {
  count                   = var.env == "prd" ? 0 : length(var.az)
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = cidrsubnet(var.cidr, 8, count.index)
  availability_zone       = element(var.az, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.namespace}_public_subnet_${count.index}_${var.env}"
  }
}


resource "aws_subnet" "private_subnet" {
  count  = var.env == "prd" ? 0 : length(var.az)
  vpc_id = aws_vpc.default_vpc.id

  cidr_block        = cidrsubnet(var.cidr, 8, count.index + 10)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "${var.namespace}_private_subnet_${count.index}_${var.env}"
  }
}

resource "aws_subnet" "database_subnet" {
  count             = var.env == "prd" ? 0 : length(var.az)
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = cidrsubnet(var.cidr, 8, count.index + 20)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "${var.namespace}_database_subnet_${count.index}_${var.env}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "${var.namespace}_igw_${var.env}"
  }
}

resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public_subnet_rta" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_subnet_rt.id
}
resource "aws_route_table" "private_subnet_rt" {
  vpc_id = aws_vpc.default_vpc.id
}
resource "aws_route_table_association" "private_subnet_rta" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_subnet_rt.id
}
resource "aws_route_table" "database_subnet_rt" {
  vpc_id = aws_vpc.default_vpc.id
}
resource "aws_route_table_association" "database_subnet_rta" {
  count          = length(aws_subnet.database_subnet)
  subnet_id      = element(aws_subnet.database_subnet.*.id, count.index)
  route_table_id = aws_route_table.database_subnet_rt.id
}

resource "aws_network_acl" "bastion_acl" {
  vpc_id     = aws_vpc.default_vpc.id
  subnet_ids = aws_subnet.public_subnet[*].id

  egress {
    protocol   = "tcp"
    rule_no    = "10"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "22"
    to_port    = "22"
  }

  egress {
    protocol   = "icmp"
    rule_no    = "11"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 8
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = "100"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = "10"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "22"
    to_port    = "22"
  }

  ingress {
    protocol   = "icmp"
    rule_no    = "11"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 8
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = "100"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "bastion_acl"
  }
}

resource "aws_network_acl" "private_server_acl" {
  vpc_id     = aws_vpc.default_vpc.id
  subnet_ids = aws_subnet.private_subnet[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = "10"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = "11"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.container_port
    to_port    = var.container_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = "12"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = "13"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1025
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = "10"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    rule_no    = "11"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = "13"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1025
    to_port    = 65535
  }


  tags = {
    Name = "private_server_acl"
  }
}

resource "aws_network_acl" "database_acl" {
  vpc_id     = aws_vpc.default_vpc.id
  subnet_ids = aws_subnet.database_subnet[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = "10"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 3306
    to_port    = 3306
  }


  egress {
    protocol   = "tcp"
    rule_no    = "10"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 3306
    to_port    = 3306
  }

  tags = {
    Name = "database_acl"
  }
}

resource "aws_vpc_endpoint" "endpoints" {
  vpc_id              = aws_vpc.default_vpc.id
  private_dns_enabled = true
  for_each            = local.endpoints
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.ap-northeast-2.${each.value.name}"
  subnet_ids          = aws_subnet.private_subnet[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = {
    Name = "${var.namespace}_${each.value.name}_${var.env}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.default_vpc.id
  service_name      = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_subnet_rt.id]

  tags = {
    Name = "${var.namespace}_s3_endpoint"
  }
}

