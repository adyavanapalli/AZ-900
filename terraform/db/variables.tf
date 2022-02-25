variable "region" {
  default     = "East US"
  description = "The Azure Region where the Resource Group should exist."
  type        = string
}

variable "username" {
  default     = "adyavanapalli"
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
}
