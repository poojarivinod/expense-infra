module "alb" { # terraform aws lbs --> application load balancer github
  source = "terraform-aws-modules/alb/aws" # it will take from github

 # expense-dev-app-alb
  name    = "${var.project_name}-${var.environment}-ingress-alb"
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  subnets = local.public_subnet_ids # this is frontend load balancer , so we need to give public subnet ids.
  create_security_group = false # terraform aws lbs --> github --> search as security_group --> inputs --> create_security_group is default is false(move side) 
  security_groups = [local.alb_ingress_sg_id] # it is the list
  internal = false # because this load balancer is open to the public
  enable_deletion_protection = false # by default it is true, if it is true we can't delete load balancer

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-ingress-alb"
    }
  )
}

resource "aws_lb_listener" "https" { #aws alb listener --> terrafrom registry
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.ingress_alb_certificate_arn

 default_action {
    type = "fixed-response" # still we don't have frontend application instance, so we are using the fixed response for testing purpose

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from frontend APP ALB</h1>"
      status_code  = "200"
  }
}  
}

resource "aws_route53_record" "web_alb" { # aws route 53 record terraform --> terraform registry
  zone_id = var.zone_id
  name    =  "expense-${var.environment}.${var.domain_name}"
  type    = "A"

# these are ALB DNS name and zone information 
  alias {
    name                   = module.alb.dns_name # it is alb dns name
    zone_id                = module.alb.zone_id # it is alb zone id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["expense-${var.environment}.${var.domain_name}"]
    }
  }
}

#target group are instance based in terraform and here target group are pod ip based
resource "aws_lb_target_group" "frontend" {
  name     = local.resource_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60
  # this is because we are attaching pod not instance, here target is ip based, in instaces terget is instance based
  target_type = "ip" # search in google as "aws_lb_target_group" --> Terraform registry
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    protocol = "HTTP"
    port = 8080
    path = "/"
    matcher = "200-299"
    interval = 10
  }
}