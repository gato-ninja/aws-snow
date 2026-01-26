variable "database_name" {
  description = "Database name"
  type = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "prefix" {
  description = "Prefix for S3 objects."
  type        = string
}

variable "snowflake_account_id" {
  description = "Snowflake account ID"
  type        = string
}

variable "snowflake_saml_provider_name" {
  description = "Name of the Snowflake SAML provider in AWS IAM"
  type        = string
}

variable "snowflake_organization_name" {
  description = "Snowflake organization name."
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name."
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake user name."
  type        = string
}

variable "snowflake_workload_identity_provider" {
  description = "OIDC Workload Identity Provider (e.g., GitHub OIDC provider URL)."
  type        = string
}

variable "aws_role_arn" {
  description = "The ARN of the AWS IAM role to assume via OIDC."
  type        = string
}

variable "aws_session_name" {
  description = "The session name for the assumed role."
  type        = string
  default     = "github-actions"
}
