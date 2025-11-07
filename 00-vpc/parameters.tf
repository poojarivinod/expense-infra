resource "aws_ssm_parameter" "vpc_id" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_id" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/public_subnet_id"
  type  = "StringList"
  value = join(",", module.vpc.public_subnet_ids) # it will convert list to string list public_subnet_ids
} # terraform join funtion --> terraform registry


resource "aws_ssm_parameter" "private_subnet_id" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/private_subnet_id"
  type  = "StringList"
  value = join(",", module.vpc.private_subnet_ids) # it will convert list to string list
} # terraform join funtion --> terraform registry

resource "aws_ssm_parameter" "database_subnet_id" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/database_subnet_id"
  type  = "StringList"
  value = join(",", module.vpc.database_subnet_ids) # it will convert list to string list
} # terraform join funtion --> terraform registry

resource "aws_ssm_parameter" "database_subnet_group_name" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/database_subnet_group_name"
  type  = "String"
  value = aws_db_subnet_group.expense.name 
} 