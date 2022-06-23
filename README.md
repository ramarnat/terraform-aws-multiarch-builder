Terraform module for building multi-architecture container images (amd64 and arm64) using remote (TLS) ephemeral EC2 instances as builders. Two AWS Spot instances are launched (one for each architecture). They both run docker (moby) in TLS mode. The module generates the remote builders and client certificates to connect and authenticate between them. The module optionally installs the certificates and applies the respective [buildx](https://github.com/docker/buildx) configuration in the client (see `create_client_certs` and `handle_client_config` input variables).

The builders are intended for ephemeral use cases, during pipelines, for instance. Therefore, [caching](https://github.com/docker/buildx/blob/master/docs/reference/buildx_build.md#cache-from) usage is also recommended.

## Dependencies
The following are the dependencies to make use of the remote ephemeral builders, once they are deployed:
* [docker](https://docs.docker.com/engine/install/)
* [buildx](https://github.com/docker/buildx)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_spot_instance_request.multiarch_builder_amd64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [aws_spot_instance_request.multiarch_builder_arm64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [local_sensitive_file.ca_cert](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.client_cert](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.client_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [null_resource.client_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_cert_request.client](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_cert_request.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.client](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.client](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.amazon_linux_amd64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.amazon_linux_arm64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [template_cloudinit_config.multiarch_builder](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az"></a> [az](#input\_az) | The multiarch builder instances availability zone | `any` | `null` | no |
| <a name="input_create_client_certs"></a> [create\_client\_certs](#input\_create\_client\_certs) | Whether client certificate files are created | `bool` | `false` | no |
| <a name="input_docker_cert_path"></a> [docker\_cert\_path](#input\_docker\_cert\_path) | Location for storing generated client docker certificates | `string` | `"~/.docker"` | no |
| <a name="input_handle_client_config"></a> [handle\_client\_config](#input\_handle\_client\_config) | Whether client buildx config is created and removed | `bool` | `false` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The multiarch builder instances iam instance profile | `any` | `null` | no |
| <a name="input_instance_type_amd64"></a> [instance\_type\_amd64](#input\_instance\_type\_amd64) | The amd64 builder instance type | `string` | `"t3.medium"` | no |
| <a name="input_instance_type_arm64"></a> [instance\_type\_arm64](#input\_instance\_type\_arm64) | The arm64 builder instance type | `string` | `"t4g.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The multiarch builder instances ssh key name | `any` | `null` | no |
| <a name="input_prefix_name"></a> [prefix\_name](#input\_prefix\_name) | The multiarch builder instances prefix name | `string` | `"multiarch-builder"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The multiarch builder instances security group ids list | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The multiarch builder instances (public) subnet id | `any` | `null` | no |
| <a name="input_tls_validity_period_hours"></a> [tls\_validity\_period\_hours](#input\_tls\_validity\_period\_hours) | Number of hours, after initial issuing, that the certificate will remain valid for | `number` | `24` | no |
| <a name="input_volume_root_size"></a> [volume\_root\_size](#input\_volume\_root\_size) | The multiarch builder instances root volume size | `number` | `15` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_cert"></a> [ca\_cert](#output\_ca\_cert) | This CA certificate |
| <a name="output_client_cert"></a> [client\_cert](#output\_client\_cert) | The client certificate sign by this CA |
| <a name="output_client_config_cmd"></a> [client\_config\_cmd](#output\_client\_config\_cmd) | Command to configure the client (docker and buildx) |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | The client private key |
