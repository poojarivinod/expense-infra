locals {
    public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
 # it will convert terraform string into list , from that list of value we take first public subnet id 
}