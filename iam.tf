data "aws_iam_policy_document" "permissions" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.simple_bucket.bucket}/${var.prefix}/*"
    ]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.simple_bucket.bucket}"
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.prefix}/*"]
    }
  }
}

data "aws_iam_policy_document" "trust_relationships" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration.integration.describe_output[0].storage_aws_iam_user_arn[0].value]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [snowflake_storage_integration.integration.describe_output[0].storage_aws_external_id[0].value]
    }
  }
}

resource "aws_iam_role" "snowflake_oidc_role" {
  name               = "snowflake-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.trust_relationships.json
}

resource "aws_iam_role_policy" "snowflake_oidc_policy" {
  name   = "snowflake-oidc-policy"
  role   = aws_iam_role.snowflake_oidc_role.id
  policy = data.aws_iam_policy_document.permissions.json
}
