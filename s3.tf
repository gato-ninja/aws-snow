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

resource "aws_s3_bucket_public_access_block" "block_public_access" {
	bucket                  = aws_s3_bucket.simple_bucket.id
	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}
