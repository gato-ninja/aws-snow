resource "snowflake_table" "table" {
  database = data.snowflake_database.database.name
  schema   = snowflake_schema.schema.name
  name     = "JSON_DATA_TABLE"

  column {
    name     = "RAW_DATA"
    type     = "VARIANT"
    nullable = true
  }

  column {
    name     = "LOADED_AT"
    type     = "TIMESTAMP_LTZ"
    nullable = true
    default {
      expression = "CURRENT_TIMESTAMP()"
    }
  }

  column {
    name     = "FILENAME"
    type     = "VARCHAR(500)"
    nullable = true
  }

  comment = "Table for storing JSON data loaded from S3 via Snowpipe"
}
