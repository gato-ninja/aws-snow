provider "snowflake" {
  organization_name          = "BCABAJN"
  account_name               = "JG57739"
  user                       = "TERRAFORM"
  authenticator              = "WORKLOAD_IDENTITY"
  workload_identity_provider = "OIDC"
  role                       = "ACCOUNTADMIN"
}

# SNOWFLAKE_TOKEN
