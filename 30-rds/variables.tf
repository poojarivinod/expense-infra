variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        project = "expense"
        environment = "dev"
        terraform = "true"
    }
}

variable "zone_id" {
    default = "Z0802349255PD9KZJ7SQF"
}

variable "domain_name" {
    default  = "poojari.store"
}