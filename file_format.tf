resource "snowflake_file_format" "example_file_format" {
  name        = "EXAMPLE_FILE_FORMAT"
  database    = data.snowflake_database.database.name
  schema      = snowflake_schema.schema.name
  format_type = "JSON"
}
