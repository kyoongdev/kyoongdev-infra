resource "aws_security_group" "alb" {
  name        = "${var.namespace}-alb-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.default_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.namespace}-vpc-endpoint-sg"
  vpc_id = aws_vpc.default_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }


  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc_endpoint_sg"
  }
}


resource "aws_security_group" "ecs_task" {
  name   = "${var.namespace}-fargate-task-sg"
  vpc_id = aws_vpc.default_vpc.id

  ingress {
    from_port   = var.container_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 1025
    to_port     =65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-task-sg"
  }

}



resource "aws_securitry_group" "database_sg"{
  name   = "${var.namespace}-database-sg"
  vpc_id = aws_vpc.default_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress{
    from_port   =0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr]
  }
}