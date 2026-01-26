terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  assume_role {
    role_arn     = var.aws_role_arn
    session_name = var.aws_session_name
  }
}
