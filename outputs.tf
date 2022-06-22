output "ca_cert" {
  description = "This CA certificate"
  value       = tls_self_signed_cert.ca.cert_pem
  sensitive   = true
}

output "client_key" {
  description = "The client private key"
  value       = tls_private_key.client.private_key_pem
  sensitive   = true
}

output "client_cert" {
  description = "The client certificate sign by this CA"
  value       = tls_locally_signed_cert.client.cert_pem
  sensitive   = true
}

output "client_config_cmd" {
  description = "Command to configure the client (docker and buildx)"
  value       = local.client_config_cmd
}
