data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}