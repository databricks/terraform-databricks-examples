# using interaction az login authentication, only need to specify subscription id
variable "subscription_id" {
  type = string
}

variable "managed_img_rg_name" {
  type = string
  default = "unique_rg_name"
}

variable "managed_img_name" {
  type = string
  default = "unique_managed_img_name"
}