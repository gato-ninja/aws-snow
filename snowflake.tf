provider "snowflake" {
  organization_name = "BCABAJN"
  account_name      = "JG57739"
  user              = "TERRAFORM"
  # authenticator              = "WORKLOAD_IDENTITY"
  # workload_identity_provider = "OIDC"
  role = "ACCOUNTADMIN"
  preview_features_enabled = ["snowflake_storage_integration_resource"]
}

# SNOWFLAKE_TOKEN
