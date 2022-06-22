locals {
  client_config_cmd = <<-EOT
    # cleanup first
    echo "about to clean up client config..."
    docker context use default || echo "ignoring error..."
    docker context rm builder_amd64 || echo "ignoring error..."
    docker context rm builder_arm64 || echo "ignoring error..."
    docker buildx use default || echo "ignoring error..."
    docker buildx rm container_builder || echo "ignoring error..."
    # config
    echo "about to set up client config..."
    docker context create \
      --docker "host=tcp://${aws_spot_instance_request.builder_amd64.public_dns}:2376,ca=${pathexpand("~/.docker/ca.pem")},cert=${pathexpand("~/.docker/cert.pem")},key=${pathexpand("~/.docker/key.pem")}" \
      --description "Remote amd64 builder" \
      builder_amd64
    docker context create \
      --docker "host=tcp://${aws_spot_instance_request.builder_arm64.public_dns}:2376,ca=${pathexpand("~/.docker/ca.pem")},cert=${pathexpand("~/.docker/cert.pem")},key=${pathexpand("~/.docker/key.pem")}" \
      --description "Remote arm64 builder" \
      builder_arm64
    ## use context and wait for initial startup
    docker context use builder_arm64
    timeout 60 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for builder_arm64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    docker context use builder_amd64
    timeout 60 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for builder_amd64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    ## set buildx builder instances
    docker context use builder_amd64
    docker buildx create --use --name container_builder \
      --driver docker-container \
      --platform linux/amd64 \
      --node=builder_amd64 \
      builder_amd64
    docker buildx create --append --name container_builder \
      --driver docker-container \
      --platform linux/arm64 \
      --node=builder_arm64 \
      builder_arm64
    docker buildx use container_builder
  EOT
}
