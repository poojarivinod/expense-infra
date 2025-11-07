module "vpc" {
    # source = "../terraform-aws-vpc" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-vpc.git?ref=main" # how to refer git terraform module --> stack overflow # if error, do "terraform init -reconfigure" # still error then, comment this source and  use above source and then come back to this source  
    project_name = var.project_name
    environment = var.environment
    vpc_cidr = var.vpc_cidr
    common_tags = var.common_tags 
    vpc_tags = var.vpc_tags
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs
    is_pairing_required = true # it override the default information of false
}

resource "aws_db_subnet_group" "expense" { # aws db subnet group terraform --> terraform registry
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = module.vpc.database_subnet_ids

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}"
    }
  )
}