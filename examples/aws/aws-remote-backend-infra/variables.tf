variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Terraform state file"
  default     = "tf-backend-bucket-haowang"
}

variable "dynamodb_table" {
  type        = string
  description = "The name of the DynamoDB table to use for state locking"
  default     = "tf-backend-dynamodb-haowang"
}

variable "dynamodb_table_databricks_project" {
  type        = string
  description = "The name of the DynamoDB table to use for state locking"
  default     = "tf-backend-dynamodb-databricks-project"
}

variable "region" {
  type        = string
  description = "The AWS region to use for the backend"
  default     = "ap-southeast-1"
}
