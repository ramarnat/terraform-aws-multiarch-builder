variable "instance_type_amd64" {
  description = "The amd64 builder instance type"
  default     = "t3.medium"
}

variable "instance_type_arm64" {
  description = "The arm64 builder instance type"
  default     = "t4g.medium"
}

variable "volume_root_size" {
  description = "The multiarch builder instances root volume size"
  default     = 15
}

variable "az" {
  description = "The multiarch builder instances availability zone"
  default     = null
}

variable "prefix_name" {
  description = "The multiarch builder instances prefix name"
  default     = "multiarch-builder"
}

variable "security_group_ids" {
  description = "The multiarch builder instances security group ids list"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "The multiarch builder instances (public) subnet id"
  default     = null
}

variable "key_name" {
  description = "The multiarch builder instances ssh key name"
  default     = null
}

variable "iam_instance_profile" {
  description = "The multiarch builder instances iam instance profile"
  default     = null
}

variable "tls_validity_period_hours" {
  description = "Number of hours, after initial issuing, that the certificate will remain valid for"
  default     = 24
}

variable "docker_cert_path" {
  description = "Location for storing generated client docker certificates"
  default     = "~/.docker"
}

variable "create_client_certs" {
  description = "Whether client certificate files are created"
  default     = false
}

variable "handle_client_config" {
  description = "Whether client buildx config is created and removed"
  default     = false
}
