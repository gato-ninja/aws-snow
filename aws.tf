provider "aws" {
  region = "us-east-2"

  # assume_role {
  #   role_arn     = "arn:aws:iam::759817713039:role/github_actions_adm"
  #   session_name = "github-actions"
  # }
}

data "aws_caller_identity" "current" {}
