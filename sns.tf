
# SNS Topic for S3 notifications
resource "aws_sns_topic" "s3_notifications" {
  name = "snowflake-s3-notifications"
}

# Get the Snowflake IAM policy for SNS access
data "snowflake_system_get_aws_sns_iam_policy" "snowflake_policy" {
  aws_sns_topic_arn = aws_sns_topic.s3_notifications.arn
}

# SNS Topic Policy Document
data "aws_iam_policy_document" "s3_notifications_policy" {
  # Allow S3 to publish notifications
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["SNS:Publish"]
    resources = [aws_sns_topic.s3_notifications.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.simple_bucket.arn]
    }
  }

  # Merge Snowflake's required SNS policy
  source_policy_documents = [
    data.snowflake_system_get_aws_sns_iam_policy.snowflake_policy.aws_sns_topic_policy_json
  ]
}

# SNS Topic Policy to allow S3 to publish and Snowflake to subscribe
resource "aws_sns_topic_policy" "s3_notifications_policy" {
  arn    = aws_sns_topic.s3_notifications.arn
  policy = data.aws_iam_policy_document.s3_notifications_policy.json
}
