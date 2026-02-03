resource "snowflake_stage" "stage" {
  database = data.snowflake_database.database.name
  schema   = snowflake_schema.schema.name
  name     = "S3_EXTERNAL_STAGE"

  url                 = "s3://${aws_s3_bucket.simple_bucket.bucket}/${var.prefix}/"
  storage_integration = snowflake_storage_integration.integration.name

  comment = "External stage for S3 bucket integration"

  depends_on = [
    snowflake_storage_integration.integration,
    aws_s3_bucket.simple_bucket
  ]
}
