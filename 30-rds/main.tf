module "db" { # terraform-aws-modules/rds/aws github
  source = "terraform-aws-modules/rds/aws"

  identifier = local.resource_name #expense-dev

  engine            = "mysql"
  engine_version    = "8.0.42"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name  = "transactions"
  username = "root"
  port     = "3306"
  password = "ExpenseApp1"
  manage_master_user_password = false
  
  vpc_security_group_ids = [local.mysql_sg_id]

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = local.database_subnet_group_name
  
  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false # if we give true, then we can't delete using terraform
  skip_final_snapshot = true # if we give true , it won't take snapshot, by default it is false. we have pay money for snapshot

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )

}

#it is route53 for endpoint of database
resource "aws_route53_record" "www-dev" {  # terraform aws route53 record --> terraform registry
  zone_id = var.zone_id
  name    = "mysql-${var.environment}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 1
  records = [module.db.db_instance_address] # terraform-aws-modules/rds/aws github
  allow_overwrite = true
}

