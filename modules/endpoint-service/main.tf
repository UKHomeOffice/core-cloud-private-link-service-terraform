###################
# Network Load Balancer
###################

resource "aws_lb" "nlb" {
  for_each = var.pl_services

  name               = each.value.name
  load_balancer_type = "network"
  internal           = true
  subnets            = var.subnet_ids
  enable_cross_zone_load_balancing = true

  tags = var.tags
}

###################
# Target Group
###################

resource "aws_lb_target_group" "tg" {
  for_each = var.pl_services

  name        = "${each.value.name}-tg"
  vpc_id      = var.vpc_id
  port        = each.value.listener_port
  protocol    = each.value.protocol
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = var.tags
}

###################
# Listener
###################

resource "aws_lb_listener" "listener" {
  for_each = var.pl_services

  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = each.value.listener_port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  tags = var.tags
}

###################
# Target Group Attachments (always 3 IPs)
###################

resource "aws_lb_target_group_attachment" "target_0" {
  for_each = var.pl_services

  target_group_arn = aws_lb_target_group.tg[each.key].arn
  target_id        = each.value.service_target_ips[0]
  port             = each.value.listener_port
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "target_1" {
  for_each = var.pl_services

  target_group_arn = aws_lb_target_group.tg[each.key].arn
  target_id        = each.value.service_target_ips[1]
  port             = each.value.listener_port
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "target_2" {
  for_each = var.pl_services

  target_group_arn = aws_lb_target_group.tg[each.key].arn
  target_id        = each.value.service_target_ips[2]
  port             = each.value.listener_port
  availability_zone = "all"
}

###################
# VPC Endpoint Service (PrivateLink)
###################

resource "aws_vpc_endpoint_service" "privatelink_service" {
  for_each = var.pl_services

  acceptance_required        = each.value.acceptance_required
  network_load_balancer_arns = [aws_lb.nlb[each.key].arn]
  allowed_principals         = each.value.allowed_principals

  tags = merge(
  var.tags,
  {
    Name        = each.value.name
  }
)
}
