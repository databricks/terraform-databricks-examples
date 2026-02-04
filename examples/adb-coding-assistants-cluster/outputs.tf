output "cluster_id" {
  description = "The ID of the created cluster"
  value       = module.claude_cluster.cluster_id
}

output "cluster_url" {
  description = "URL to access the cluster in Databricks UI"
  value       = module.claude_cluster.cluster_url
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = module.claude_cluster.cluster_name
}

output "volume_path" {
  description = "Path to the volume containing init scripts"
  value       = module.claude_cluster.volume_path
}

output "volume_full_name" {
  description = "Full name of the volume"
  value       = module.claude_cluster.volume_full_name
}

output "init_script_path" {
  description = "Path to the init script in the volume"
  value       = module.claude_cluster.init_script_path
}

output "mlflow_experiment_name" {
  description = "MLflow experiment name for tracing"
  value       = module.claude_cluster.mlflow_experiment_name
}

output "setup_instructions" {
  description = "Instructions for using the cluster"
  value       = <<-EOT
    Cluster deployed successfully!
    
    1. Access cluster: ${module.claude_cluster.cluster_url}
    2. Wait for cluster to start (init script runs automatically)
    3. Open a notebook or terminal
    4. Run: source ~/.bashrc
    5. Verify: check-claude
    6. Start using: claude "your question"
    
    MLflow Experiment: ${module.claude_cluster.mlflow_experiment_name}
    
    Helper commands:
    - check-claude: Verify installation status
    - claude-debug: Show configuration details
    - claude-refresh-token: Update authentication
    - claude-tracing-enable: Enable MLflow tracing
    - claude-tracing-status: Check tracing status
    - claude-tracing-disable: Disable tracing
  EOT
}
