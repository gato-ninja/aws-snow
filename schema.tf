resource "snowflake_schema" "schema" {
  database = data.snowflake_database.database.name
  name     = "schema_name"
}
