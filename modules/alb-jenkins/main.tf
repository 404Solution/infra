terraform {
  backend "s3" {}
}

resource "aws_security_group" "alb" {
  name        = "${var.env}-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-alb-sg"
  }
}


resource "aws_lb" "jenkins_lb" {
  name               = "dev-alb-jenkins"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = ["subnet-06bc80554f02d8614", "subnet-0d62abcf68a067b35", "subnet-00395acff911333e0"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:339713128680:certificate/3349765c-e105-430f-bc19-425aa8596cd1"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}



resource "aws_lb_target_group" "jenkins_tg" {
  name     = "${var.env}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/login"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.env}-tg"
  }
}


resource "aws_lb_target_group_attachment" "jenkins_tg_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = "i-029209f023b41026e"
  port             = 8080
}




resource "aws_route53_record" "jenkins" {
  zone_id = "Z0562819A0NS5ORS563N"
  name    = "jenkins.cloudservicescitylabs.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.jenkins_lb.dns_name]
}
