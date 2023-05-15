resource "aws_lb" "internet_facing" {
  name               = "${var.namespace}-internet-facing-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.private_subnet[*].id

  tags = {
    Name = "${var.namespace}-internet-facing-lb"
  }
}