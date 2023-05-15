resource "aws_alb" "internet_facing" {
  name               = "${var.namespace}-internet-facing-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.private_subnet[*].id

  tags = {
    Name = "${var.namespace}-internet-facing-lb"
  }

  lifecycle { create_before_destroy = true }

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.internet_facing.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "alb_tg" {
  name        = "${var.namespace}-ip-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.default_vpc.id

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags ={
    Name = "${var.namespace}-ip-tg"
  }
}

/* resource "aws_alb_target_group_attachment" "static" {
  target_group_arn = "${aws_alb_target_group.static.arn}"
  target_id        = "${aws_instance.static.id}"
  port             = 8080
} */