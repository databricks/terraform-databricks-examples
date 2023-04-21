output "overwatch_ws_config_file" {
  value = data.template_file.ow-deployment-config.rendered
}