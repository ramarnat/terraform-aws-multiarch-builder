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
