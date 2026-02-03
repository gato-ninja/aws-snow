resource "aws_s3_bucket" "simple_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "expire_objects" {
  bucket = aws_s3_bucket.simple_bucket.id

  rule {
    id     = "expire-objects-after-2-days"
    status = "Enabled"

    expiration {
      days = 2
    }
  }
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "snowflake_notifications" {
  bucket = aws_s3_bucket.simple_bucket.id

  topic {
    topic_arn = aws_sns_topic.s3_notifications.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = "${var.prefix}/"
    filter_suffix = ".json"
  }

  depends_on = [
    aws_sns_topic_policy.s3_notifications_policy,
    snowflake_pipe.pipe
  ]
}
