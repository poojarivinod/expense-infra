#This is aws authentication with eks
# search in google as "aws key pair terraform" -->  Terraform Registry
resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+WhJTuT6q5qyTtSsE5dKFsFwIu1E+bpTAEufyntMqY Admin@DESKTOP-107I85T" # pub key of devops
}

# search in google as "terraform aws eks"--> click on "Terraform Registry" --> click on github.com/terraform-aws-modules/terraform-aws-eks --> scroll down --> EKS Managed Node Group
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version =  "~> 21.0"

  name               = local.name
  kubernetes_version = "1.32" # later we upgrade to 1.33
  #kubernetes_version = "1.33" 
  create_node_security_group = false #default eks node creates its own security group,we don't want default security group for node
  create_security_group = false #default eks node creates its own security group,we don't want default security group for node
  security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id
 
  #bootstrap_self_managed_addons = false
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
    metrics-server = {}
  }

  # Optional
  endpoint_public_access = false #we need cluster endpoint to be private 

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = { # ec2 --> IAM --> policies 
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" # search as ebs --> click on AmazonEBSCSIDriverPolicy to get arn
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy" # search as efs --> click on AmazonEFSCSIDriverPolicy to get arn
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
      
    #   green = {
    #   # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    #   ami_type       = "AL2023_x86_64_STANDARD"
    #   instance_types = ["m5.xlarge"]
    #   key_name = aws_key_pair.eks.key_name

    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   iam_role_additional_policies = { # ec2 --> IAM --> policies 
    #     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" # search as ebs --> click on AmazonEBSCSIDriverPolicy to get arn
    #     AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy" # search as efs --> click on AmazonEFSCSIDriverPolicy to get arn
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess" # search as ElasticLoadBalancing --> click on ElasticLoadBalancingFullAccess to get arn
    #   }
    # }
  }
 
 tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}