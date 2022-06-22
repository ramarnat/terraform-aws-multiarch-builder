variable "subnet_id" {
  description = "The builder instances (public) subnet id"
}

variable "security_group_ids" {
  description = "The builder instances security group ids list"
  type        = list(string)
}

variable "create_client_certs" {
  description = "Whether client certificate files are created"
  default     = true
}

variable "handle_client_config" {
  description = "Whether client buildx config is created and removed"
  default     = true
}
