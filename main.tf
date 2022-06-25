data "template_cloudinit_config" "multiarch_builder" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = <<TEMPLATE
package_update: true
packages:
  - moby
write_files:
  - path: /root/.docker/ca.pem
    encoding: b64
    permissions: '0640'
    owner: root:root
    content: ${base64encode(tls_self_signed_cert.ca.cert_pem)}
  - path: /root/.docker/cert.pem
    encoding: b64
    permissions: '0640'
    owner: root:root
    content: ${base64encode(tls_locally_signed_cert.server.cert_pem)}
  - path: /root/.docker/key.pem
    encoding: b64
    permissions: '0640'
    owner: root:root
    content: ${base64encode(tls_private_key.server.private_key_pem)}
  - path: /etc/systemd/system/docker.service.d/override.conf
    permissions: '0644'
    owner: root:root
    content: |
      [Service]
      ExecStart=
      ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock $OPTIONS $DOCKER_STORAGE_OPTIONS $DOCKER_ADD_RUNTIMES
  - path: /etc/docker/daemon.json
    permissions: '0644'
    owner: root:root
    content: |
      {
        "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
        "tlsverify": true,
        "tlscacert": "/root/.docker/ca.pem",
        "tlscert": "/root/.docker/cert.pem",
        "tlskey": "/root/.docker/key.pem"
      }
runcmd:
  - 'dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_$(if [ `uname -m` == "x86_64" ]; then echo "amd64"; else echo "arm64"; fi)/amazon-ssm-agent.rpm'
  - 'systemctl daemon-reload'
  - 'systemctl enable amazon-ssm-agent'
  - 'systemctl enable docker'
  - 'systemctl start amazon-ssm-agent'
  - 'systemctl start docker'
TEMPLATE
  }
}

data "aws_ami" "amazon_linux_amd64" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "al2022-ami-minimal-*"

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "amazon_linux_arm64" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "al2022-ami-*"

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_spot_instance_request" "multiarch_builder_amd64" {
  count = var.create_amd64 ? 1 : 0

  ami                         = data.aws_ami.amazon_linux_amd64.id
  instance_type               = var.instance_type_amd64
  availability_zone           = var.az
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  user_data_base64            = data.template_cloudinit_config.multiarch_builder.rendered
  user_data_replace_on_change = true
  wait_for_fulfillment        = true
  associate_public_ip_address = true

  instance_interruption_behavior = "terminate"
  spot_type                      = "one-time"

  root_block_device {
    volume_size = var.volume_root_size
    volume_type = "gp3"
  }

  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name            = "${var.prefix_name}-amd64"
    TerraformModule = "multiarch-builder"
  }
}

resource "aws_spot_instance_request" "multiarch_builder_arm64" {
  count = var.create_arm64 ? 1 : 0

  ami                         = data.aws_ami.amazon_linux_arm64.id
  instance_type               = var.instance_type_arm64
  availability_zone           = var.az
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  user_data_base64            = data.template_cloudinit_config.multiarch_builder.rendered
  user_data_replace_on_change = true
  wait_for_fulfillment        = true
  associate_public_ip_address = true

  instance_interruption_behavior = "terminate"
  spot_type                      = "one-time"

  root_block_device {
    volume_size = var.volume_root_size
    volume_type = "gp3"
  }

  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name            = "${var.prefix_name}-arm64"
    TerraformModule = "multiarch-builder"
  }
}

resource "null_resource" "client_config_amd64" {
  count = var.handle_client_config && var.create_amd64 ? 1 : 0

  provisioner "local-exec" {
    command     = local.client_config_amd64_cmd
    interpreter = ["/bin/bash", "-c"]
    when        = create
  }

  provisioner "local-exec" {
    command     = <<-EOT
    docker context use default || echo "ignoring error..."; \
    docker context rm multiarch-builder-amd64 || echo "ignoring error..."; \
    docker buildx use default || echo "ignoring error..."; \
    docker buildx rm multiarch-builder-amd64 || echo "ignoring error..."
    docker buildx rm --all-inactive -f || echo "ignoring error..."
    EOT
    interpreter = ["/bin/bash", "-c"]
    when        = destroy
  }
}

resource "null_resource" "client_config_arm64" {
  count = var.handle_client_config && var.create_arm64 ? 1 : 0

  provisioner "local-exec" {
    command     = local.client_config_arm64_cmd
    interpreter = ["/bin/bash", "-c"]
    when        = create
  }

  provisioner "local-exec" {
    command     = <<-EOT
    docker context use default || echo "ignoring error..."
    docker context rm multiarch-builder-arm64 || echo "ignoring error..."
    docker buildx use default || echo "ignoring error..."
    docker buildx rm multiarch-builder-arm64 || echo "ignoring error..."
    docker buildx rm --all-inactive -f || echo "ignoring error..."
    EOT
    interpreter = ["/bin/bash", "-c"]
    when        = destroy
  }
}
