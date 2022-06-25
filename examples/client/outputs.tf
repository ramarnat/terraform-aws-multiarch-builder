output "ca_cert" {
  description = "This CA certificate"
  value       = module.multiarch_builder.ca_cert
  sensitive   = true
}

output "client_key" {
  description = "The client private key"
  value       = module.multiarch_builder.client_key
  sensitive   = true
}

output "client_cert" {
  description = "The client certificate sign by this CA"
  value       = module.multiarch_builder.client_cert
  sensitive   = true
}

output "client_config_cmd" {
  description = "Command to configure the client (docker and buildx)"
  value       = module.multiarch_builder.client_config_cmd
}

output "client_config_amd64_cmd" {
  description = "Command to configure the client (docker and buildx) with amd64 instance"
  value       = module.multiarch_builder.client_config_amd64_cmd
}

output "client_config_arm64_cmd" {
  description = "Command to configure the client (docker and buildx) with arm64 instance"
  value       = module.multiarch_builder.client_config_arm64_cmd
}

output "docker_host_amd64" {
  description = "Docker host (TLS) for amd64 instance"
  value       = module.multiarch_builder.docker_host_amd64
}

output "docker_host_arm64" {
  description = "Docker host (TLS) for arm64 instance"
  value       = module.multiarch_builder.docker_host_arm64
}
