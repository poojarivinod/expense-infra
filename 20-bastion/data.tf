# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "bastion_sg_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/bastion_sg_id"
}

# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "public_subnet_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/public_subnet_id"
} # we get output in string of public subnet ids