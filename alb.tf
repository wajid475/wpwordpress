# Application Load Balancer
resource "aws_lb" "wordpress" {
  name               = "${var.owner}-wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "wordpress" {
  name        = "${var.owner}-wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-listener"
  }
}
