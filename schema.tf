resource "snowflake_schema" "schema" {
  database = snowflake_database.database.name
  name     = "schema_name"
}
