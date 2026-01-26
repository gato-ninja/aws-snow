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
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.snowflake_account_id}:saml-provider/${var.snowflake_saml_provider_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}
