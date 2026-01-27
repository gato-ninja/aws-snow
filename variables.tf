variable "database_name" {
  description = "Database name"
  type        = string
  default     = "super_teste_incrivel"
}

variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
  default     = "superf-023kd-3-dsa"
}

variable "prefix" {
  description = "Prefix for S3 objects."
  type        = string
  default     = "app/data"
}
