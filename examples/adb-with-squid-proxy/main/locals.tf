locals {
  prefix    = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location  = var.rglocation
  squidcidr = var.vnetcidr
  dbcidr    = var.dbvnetcidr
  // tags that are propagated down to all resources
  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}
