resource "databricks_workspace_conf" "just_config_map" {
  custom_config = {
    "enableResultsDownloading"      = "false",
    "enableNotebookTableClipboard"  = "false",
    "enableVerboseAuditLogs"        = "true",
    "enable-X-Frame-Options"        = "true",
    "enable-X-Content-Type-Options" = "true",
    "enable-X-XSS-Protection"       = "true",
    "enableWebTerminal"             = "false",
    "enableDbfsFileBrowser"         = "false",
    "enforceUserIsolation"          = "true",
    "enableNotebookGitVersioning"   = "true"
  }
}