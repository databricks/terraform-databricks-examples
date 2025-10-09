module "pl-secretsmanager" {
  source                         = "../../modules/aws-serverless-privatelink-to-cloud-service"
  vpc_id                         = var.vpc_id
  private_subnet_ids             = var.private_subnet_ids
  network_connectivity_config_id = var.network_connectivity_config_id
  aws_service                    = "secretsmanager" # gets interpolated to: com.amazonaws.${var.region}.${var.aws_service}
  region                         = var.region
  prefix                         = "pl-secretsmanager"
}
