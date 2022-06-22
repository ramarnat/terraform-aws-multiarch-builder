resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  ecdsa_curve = "P521"
  rsa_bits    = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = var.tls_validity_period_hours

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = "${var.prefix_name}-ca"
    organization = "${var.prefix_name} ca"
  }
}

resource "tls_private_key" "server" {
  algorithm   = "RSA"
  ecdsa_curve = "P521"
  rsa_bits    = 4096
}

resource "tls_private_key" "client" {
  algorithm   = "RSA"
  ecdsa_curve = "P521"
  rsa_bits    = 4096
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  dns_names = ["*.compute-1.amazonaws.com", "*.*.amazonaws.com"]

  subject {
    common_name  = "${var.prefix_name}-server"
    organization = "${var.prefix_name} server"
  }
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = "${var.prefix_name}-client"
    organization = "${var.prefix_name} client"
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem = tls_cert_request.server.cert_request_pem

  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.tls_validity_period_hours

  allowed_uses = [
    "server_auth",
  ]
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem = tls_cert_request.client.cert_request_pem

  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.tls_validity_period_hours

  allowed_uses = [
    "client_auth",
  ]
}

resource "local_sensitive_file" "ca_cert" {
  count = var.create_client_certs ? 1 : 0

  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${pathexpand(var.docker_cert_path)}/ca.pem"
}

resource "local_sensitive_file" "client_cert" {
  count = var.create_client_certs ? 1 : 0

  content  = tls_locally_signed_cert.client.cert_pem
  filename = "${pathexpand(var.docker_cert_path)}/cert.pem"
}

resource "local_sensitive_file" "client_key" {
  count = var.create_client_certs ? 1 : 0

  content  = tls_private_key.client.private_key_pem
  filename = "${pathexpand(var.docker_cert_path)}/key.pem"
}
