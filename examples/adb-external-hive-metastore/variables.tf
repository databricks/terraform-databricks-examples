variable "spokecidr" {
  type    = string
  default = "10.179.0.0/20"
}

variable "sqlvnetcidr" {
  type    = string
  default = "10.178.0.0/20"
}

variable "no_public_ip" {
  type    = bool
  default = true
}

variable "rglocation" {
  type    = string
  default = "southeastasia"
}

variable "dbfs_prefix" {
  type    = string
  default = "dbfs"
}

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "cold_start" {
  description = "if true, will spin up a cluster to download hive jars to dbfs"
  type        = bool
  default     = true # set to true to use a cluster to initialize hive schema
}
