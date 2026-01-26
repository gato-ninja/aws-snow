terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

provider "snowflake" {
  preview_features_enabled = []
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  authenticator     = "WORKLOAD_IDENTITY"
  workload_identity_provider = var.snowflake_workload_identity_provider
}
