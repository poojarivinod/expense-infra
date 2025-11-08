# security group module for mysql
module "mysql_sg" {
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "created for MySQL instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# backend and frontend are not required because we are maintaining in kubernetes

# security group module for bastion
module "bastion_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "created for bastion instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for vpn , vpn ports are 22, 443, 1194, 943.
module "vpn_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "vpn"
    sg_description = "created for vpn instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for app_alb 
module "alb_ingress_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "alb_ingress"
    sg_description = "created for backend ALB instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for eks 
module "eks_control_plane_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-control-plane"
    sg_description = "created for backend ALB instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for eks-node
module "eks_node_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-node"
    sg_description = "created for backend ALB instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# eks_node accept the traffic from eks_control_plane
resource "aws_security_group_rule" "eks_node_eks_control_plane" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 0 # from all ports
  to_port           = 0 # to all ports
  protocol          = "-1" # -1 means all tcp
  source_security_group_id    =  module.eks_control_plane_sg.sg_id # accept bastion host id
  security_group_id = module.eks_node_sg.sg_id
}

# eks_control_plane accept the traffic from eks_node
resource "aws_security_group_rule" "eks_control_plane_eks_node" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 0 # from all ports
  to_port           = 0 # to all ports
  protocol          = "-1" # -1 means all tcp
  source_security_group_id    =  module.eks_node_sg.sg_id # accept bastion host id
  security_group_id = module.eks_control_plane_sg.sg_id
}

#eks_node accept the traffic from eks_alb_ingress
# resource "aws_security_group_rule" "eks_node_alb_ingress" { # terraform aws security group rule --> terraform registry
#   type              = "ingress"
#   from_port         = 30000 #ephemeral ports range from 30000 to 32767
#   to_port           = 32767
#   protocol          = "tcp" 
#   source_security_group_id    =  module.alb_ingress_sg.sg_id 
#   security_group_id = module.eks_node_sg.sg_id
# }

# eks_node accept the traffic from vpc
resource "aws_security_group_rule" "eks_node_vpc" { # pod to accept traffic from database, other pods from other node etc, so we need use ["10.0.0.0/16"] for internal network
  type              = "ingress"
  from_port         = 0 
  to_port           = 0
  protocol          =  "-1" #this is huge mistake, if value is tcp, DNS will work in EKS. UDP traffic is required. So make it All traffic
   cidr_blocks = ["10.0.0.0/16"] # our private IP address range
  security_group_id = module.eks_node_sg.sg_id
}

# eks_node accept the traffic from bastion
resource "aws_security_group_rule" "eks_node_bastion" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp" 
  source_security_group_id    =  module.bastion_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

# alb ingress accept the traffic from bastion host
resource "aws_security_group_rule" "alb_ingress_bastion" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id    =  module.bastion_sg.sg_id # accept bastion host id
  security_group_id = module.alb_ingress_sg.sg_id
}

# alb ingress accept the traffic from bastion host on https
resource "aws_security_group_rule" "alb_ingress_bastion_https" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id    =  module.bastion_sg.sg_id # accept bastion host id
  security_group_id = module.alb_ingress_sg.sg_id
}

# alb ingress accept the traffic from public on https
resource "aws_security_group_rule" "alb_ingress_public_https" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  security_group_id = module.alb_ingress_sg.sg_id
}

# To get traffic from internet to bastion
resource "aws_security_group_rule" "bastion_public" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # we can give home ip address(search in internet as "what is my ip"), it is dynamic ip addreess, in company we have purchased static ip address we use it
  security_group_id = module.bastion_sg.sg_id
}

# mysql accept the traffic from bastion
resource "aws_security_group_rule" "mysql_bastion" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

# mysql accept the traffic from eks-node
resource "aws_security_group_rule" "mysql_eks_node" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

# eks_control_plane accept the traffic from bastion
resource "aws_security_group_rule" "eks_control_plane_bastion" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

# eks_node accept the traffic from alb_ingress
# resource "aws_security_group_rule" "eks_node_alb_ingress" { 
#   type              = "ingress"
#   from_port         = 8080
#   to_port           = 8080
#   protocol          = "tcp"
#   source_security_group_id = module.alb_ingress_sg.sg_id
#   security_group_id = module.eks_node_sg.sg_id
# }
