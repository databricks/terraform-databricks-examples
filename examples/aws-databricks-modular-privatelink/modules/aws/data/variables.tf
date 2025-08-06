variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "data_bucket_name" {
  type        = string
  description = "Name of the S3 data bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}