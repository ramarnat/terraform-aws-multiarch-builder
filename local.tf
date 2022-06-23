locals {
  client_config_cmd = <<-EOT
    # cleanup first
    echo "about to clean up client config..."
    docker context use default || echo "ignoring error..."
    docker context rm multiarch-builder-arm64 || echo "ignoring error..."
    docker context rm multiarch-builder-arm64 || echo "ignoring error..."
    docker buildx use default || echo "ignoring error..."
    docker buildx rm multiarch-builder || echo "ignoring error..."
    # config
    echo "about to set up client config..."
    docker context create \
      --docker "host=tcp://${aws_spot_instance_request.multiarch_builder_amd64.public_dns}:2376,ca=${pathexpand("~/.docker/ca.pem")},cert=${pathexpand("~/.docker/cert.pem")},key=${pathexpand("~/.docker/key.pem")}" \
      --description "Remote amd64 builder for multiarch-builder instance" \
      multiarch-builder-arm64
    docker context create \
      --docker "host=tcp://${aws_spot_instance_request.multiarch_builder_arm64.public_dns}:2376,ca=${pathexpand("~/.docker/ca.pem")},cert=${pathexpand("~/.docker/cert.pem")},key=${pathexpand("~/.docker/key.pem")}" \
      --description "Remote arm64 builder for multiarch-builder instance" \
      multiarch-builder-arm64
    ## use context and wait for initial startup
    docker context use multiarch-builder-arm64
    timeout 120 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for multiarch-builder-arm64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    docker context use multiarch-builder-arm64
    timeout 120 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for multiarch-builder-arm64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    ## set buildx builder instances
    docker context use multiarch-builder-arm64
    docker buildx create --use --name multiarch-builder \
      --driver docker-container \
      --platform linux/amd64 \
      --node=multiarch-builder-arm64 \
      multiarch-builder-arm64
    docker buildx create --append --name multiarch-builder \
      --driver docker-container \
      --platform linux/arm64 \
      --node=multiarch-builder-arm64 \
      multiarch-builder-arm64
    docker buildx use multiarch-builder
  EOT
}
