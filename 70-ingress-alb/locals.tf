locals {
    public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_id.value)
# in aws value are stored in the form of stringlist, which converted into  list
    alb_ingress_sg_id = data.aws_ssm_parameter.alb_ingress_sg_id.value
    ingress_alb_certificate_arn = data.aws_ssm_parameter.ingress_alb_certificate_arn.value
    resource_name = "${var.project_name}-${var.environment}"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}