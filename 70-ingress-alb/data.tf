data "aws_ssm_parameter" "vpc_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "public_subnet_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/public_subnet_id"
} # we get output in string of public subnet ids

data "aws_ssm_parameter" "alb_ingress_sg_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/alb_ingress_sg_id"
}

data "aws_ssm_parameter" "ingress_alb_certificate_arn" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/ingress_alb_certificate_arn"
}
