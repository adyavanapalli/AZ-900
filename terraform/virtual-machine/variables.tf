# variable "public_key" {
#   description = "The public key which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format."
#   sensitive   = true
#   type        = string
# }

variable "username" {
  default     = "adyavanapalli"
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
}
