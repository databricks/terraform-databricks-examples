variable "team" {
  type        = string
}

variable "policy_overrides" {
  type        =  map(object({type = string, value = string}))
}