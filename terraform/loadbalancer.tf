# Define security group for load balancer
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssl_ingress" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_egress" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
# Define a load balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.my_subnetA.id, aws_subnet.my_subnetB.id]
  enable_deletion_protection = false

  tags = {
    Name = "my_lb"
  }
}
# Define a target group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.my_vpc.id


  tags = {
    Name = "my_target_group"
  }
}
# Define a listener
resource "aws_lb_listener" "my_ssh_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.my_certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
}
#Associate EC2 instanceA with the target group
resource "aws_lb_target_group_attachment" "my_target_group_attachmentA" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instanceA.id
  port             = 443
}
#Associate EC2 instanceB with the target group
resource "aws_lb_target_group_attachment" "my_target_group_attachmentB" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instanceB.id
  port             = 443
}
