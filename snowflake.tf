provider "snowflake" {
  organization_name = "BCABAJN"
  account_name      = "JG57739"
  user              = "TERRAFORM"
  # authenticator              = "WORKLOAD_IDENTITY"
  # workload_identity_provider = "OIDC"
  role = "ACCOUNTADMIN"
  preview_features_enabled = [
    "snowflake_storage_integration_resource",
    "snowflake_pipe_resource",
    "snowflake_stage_resource",
    "snowflake_table_resource",
    "snowflake_file_format_resource",
    "snowflake_system_get_aws_sns_iam_policy_datasource"
  ]
}

# SNOWFLAKE_TOKEN
