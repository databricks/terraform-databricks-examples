variable "databricks_profile" {
  description = "Databricks CLI profile name from ~/.databrickscfg (recommended for simple, cloud-agnostic authentication). If set, databricks_resource_id is ignored."
  type        = string
  default     = null
}

variable "databricks_resource_id" {
  description = "The Azure resource ID for the Databricks workspace (Azure-specific approach). Format: /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Databricks/workspaces/{workspace-name}. Only used if databricks_profile is not set."
  type        = string
  default     = null

  validation {
    condition     = var.databricks_profile != null || var.databricks_resource_id != null
    error_message = "Either databricks_profile or databricks_resource_id must be set. Recommended: use databricks_profile for simpler configuration."
  }
}

variable "cluster_name" {
  description = "Name of the Databricks cluster"
  type        = string
}

variable "catalog_name" {
  description = "Unity Catalog name for the volume"
  type        = string
}

variable "schema_name" {
  description = "Schema name for the volume"
  type        = string
  default     = "default"
}

variable "volume_name" {
  description = "Volume name to store init scripts"
  type        = string
  default     = "coding_assistants"
}

variable "init_script_source_path" {
  description = "Local path to the init script"
  type        = string
  default     = null
}

variable "spark_version" {
  description = "Databricks Runtime version"
  type        = string
  default     = "17.3.x-cpu-ml-scala2.13"
}

variable "node_type_id" {
  description = "Node type for the cluster. Default is Standard_D8pds_v6 (modern, premium SSD + local NVMe). If unavailable in your region, consider Standard_DS13_v2 as fallback."
  type        = string
  default     = "Standard_D8pds_v6"
}

variable "autotermination_minutes" {
  description = "Minutes of inactivity before cluster auto-terminates"
  type        = number
  default     = 30
}

variable "num_workers" {
  description = "Number of worker nodes (null for autoscaling)"
  type        = number
  default     = null
}

variable "min_workers" {
  description = "Minimum number of workers for autoscaling"
  type        = number
  default     = 1
}

variable "max_workers" {
  description = "Maximum number of workers for autoscaling"
  type        = number
  default     = 3
}

variable "mlflow_experiment_name" {
  description = "MLflow experiment name for Claude Code tracing"
  type        = string
  default     = "/Workspace/Shared/claude-code-tracing"
}

variable "cluster_mode" {
  description = "Cluster mode: STANDARD or SINGLE_NODE"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "SINGLE_NODE"], var.cluster_mode)
    error_message = "cluster_mode must be either STANDARD or SINGLE_NODE"
  }
}

variable "tags" {
  description = "Custom tags for the cluster"
  type        = map(string)
  default = {
    Environment = "dev"
    Purpose     = "coding-assistants"
  }
}
