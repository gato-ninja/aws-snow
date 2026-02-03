resource "snowflake_pipe" "pipe" {
  database = snowflake_database.database.name
  schema   = snowflake_schema.schema.name
  name     = "S3_DATA_PIPE"

  comment = "Pipe for automatically loading data from S3 to Snowflake table"

  copy_statement = <<SQL
    COPY INTO ${snowflake_table.table.fully_qualified_name} (RAW_DATA, LOADED_AT, FILENAME)
    FROM (
      SELECT $1, CURRENT_TIMESTAMP(), METADATA$FILENAME
      FROM @${snowflake_stage.stage.fully_qualified_name}
    )
    FILE_FORMAT = (FORMAT_NAME = '${snowflake_file_format.example_file_format.fully_qualified_name}')
    ON_ERROR = 'CONTINUE'
  SQL

  auto_ingest        = true
  aws_sns_topic_arn = aws_sns_topic.s3_notifications.arn

  depends_on = [
    snowflake_table.table,
    snowflake_stage.stage,
    snowflake_file_format.example_file_format,
    aws_sns_topic.s3_notifications
  ]
}
