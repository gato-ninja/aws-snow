resource "snowflake_database" "database" {
  name = var.database_name
  comment = "Database created by Terraform for snow studies project"
}
