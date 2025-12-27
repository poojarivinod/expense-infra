terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
  backend "s3" { #s3 terraform backend
    bucket = "vinod-tf-remote-state-dev"
    key    = "expense-dev-web-alb" #you should have unique keys with in the buckets, same key should not used in other repos or tf project
    region = "us-east-1"
    dynamodb_table = "vinod-tf-remote-state-dev" # dynamodb_table terraform --> spacelift
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}