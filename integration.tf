resource "snowflake_storage_integration" "integration" {
  name                      = "storage"
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  storage_allowed_locations = ["s3://${aws_s3_bucket.simple_bucket.bucket}/${var.prefix}/"]

  storage_provider     = "S3"
  storage_aws_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/snowflake-oidc-role"
}
