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

output "client_config_amd64_cmd" {
  description = "Command to configure the client (docker and buildx) with amd64 instance"
  value       = local.client_config_amd64_cmd
}

output "client_config_arm64_cmd" {
  description = "Command to configure the client (docker and buildx) with arm64 instance"
  value       = local.client_config_arm64_cmd
}

output "docker_host_amd64" {
  description = "Docker host (TLS) for amd64 instance"
  value       = try("tcp://${aws_spot_instance_request.multiarch_builder_amd64[0].public_dns}:2376", "")
}

output "docker_host_arm64" {
  description = "Docker host (TLS) for arm64 instance"
  value       = try("tcp://${aws_spot_instance_request.multiarch_builder_arm64[0].public_dns}:2376", "")
}
