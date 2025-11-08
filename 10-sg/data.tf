# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "vpc_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/vpc_id"
}