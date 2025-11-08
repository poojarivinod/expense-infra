# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "vpc_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

# it read the content of /expense/dev//private_subnet_id ssm parameter
data "aws_ssm_parameter" "private_subnet_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/private_subnet_id"
} # we get output in string of private subnet ids

data "aws_ssm_parameter" "eks_control_plane_sg_id" {
  name = "/${var.project_name}/${var.environment}/eks_control_plane_sg_id"
}

data "aws_ssm_parameter" "eks_node_sg_id" {
  name = "/${var.project_name}/${var.environment}/eks_node_sg_id"
}