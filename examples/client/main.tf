module "multiarch_builder" {
  source = "krestomatio/aws/multiarch-builder"

  subnet_id            = var.subnet_id
  security_group_ids   = var.security_group_ids
  create_client_certs  = var.create_client_certs
  handle_client_config = var.handle_client_config
}
