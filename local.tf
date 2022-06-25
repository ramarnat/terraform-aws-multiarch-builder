locals {
  client_config_amd64_cmd = <<-EOT
    set -eu
    # vars
    unset DOCKER_HOST
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH='${pathexpand(var.docker_cert_path)}'
    # cleanup first
    docker context use default || echo "ignoring error..."; \
    docker context rm multiarch-builder-amd64 || echo "ignoring error..."; \
    docker buildx use default || echo "ignoring error..."; \
    docker buildx rm --all-inactive || echo "ignoring error..."
    # config
    %{if var.create_amd64~}
    echo "about to set up client config for amd64 instance..."
    docker context create \
        --docker host=tcp://${aws_spot_instance_request.multiarch_builder_amd64[0].public_dns}:2376,ca="${pathexpand(var.docker_cert_path)}/ca.pem",cert="${pathexpand(var.docker_cert_path)}/cert.pem",key="${pathexpand(var.docker_cert_path)}/key.pem" \
        --description "Remote amd64 builder for multiarch-builder instance" \
        multiarch-builder-amd64
    ## use context and wait for initial startup
    echo "about to set up docker context 'multiarch-builder-amd64'..."
    docker context use multiarch-builder-amd64
    timeout 120 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for multiarch-builder-amd64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    ## set buildx builder instances
    echo "about to set up buildx node 'multiarch-builder-amd64'..."
    docker buildx create --use --name multiarch-builder \
        --driver docker-container \
        --platform linux/amd64 \
        --node=multiarch-builder-amd64 \
        multiarch-builder-amd64
    %{endif~}
    ## force init multiarch-builder instances
    echo "force init 'multiarch-builder' instance..."
    echo -e "FROM scratch\nCOPY Dockerfile.init-multiarch-builder Dockerfile.init-multiarch-builder" > Dockerfile.init-multiarch-builder
    docker buildx build --platform="linux/amd64" -f Dockerfile.init-multiarch-builder .
    rm Dockerfile.init-multiarch-builder
  EOT
  client_config_arm64_cmd = <<-EOT
    set -eu
    # vars
    unset DOCKER_HOST
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH='${pathexpand(var.docker_cert_path)}'
    # cleanup first
    docker context use default || echo "ignoring error..."; \
    docker context rm multiarch-builder-arm64 || echo "ignoring error..."; \
    docker buildx use default || echo "ignoring error..."; \
    docker buildx rm --all-inactive || echo "ignoring error..."
    # config
    %{if var.create_arm64~}
    echo "about to set up client config for arm64 instance..."
    docker context create \
        --docker host=tcp://${aws_spot_instance_request.multiarch_builder_arm64[0].public_dns}:2376,ca="${pathexpand(var.docker_cert_path)}/ca.pem",cert="${pathexpand(var.docker_cert_path)}/cert.pem",key="${pathexpand(var.docker_cert_path)}/key.pem" \
        --description "Remote arm64 builder for multiarch-builder instance" \
        multiarch-builder-arm64
    ## use context and wait for initial startup
    echo "about to set up docker context 'multiarch-builder-arm64'..."
    docker context use multiarch-builder-arm64
    timeout 120 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for multiarch-builder-arm64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    ## set buildx builder instances
    echo "about to set up buildx node 'multiarch-builder-arm64'..."
    %{if var.create_amd64~}
    docker buildx create --append --name multiarch-builder \
    %{else~}
    docker buildx create --use --name multiarch-builder \
    %{endif~}
        --driver docker-container \
        --platform linux/arm64 \
        --node=multiarch-builder-arm64 \
        multiarch-builder-arm64
    %{endif~}
    ## force init multiarch-builder instances
    echo "force init 'multiarch-builder' instance..."
    echo -e "FROM scratch\nCOPY Dockerfile.init-multiarch-builder Dockerfile.init-multiarch-builder" > Dockerfile.init-multiarch-builder
    docker buildx build --platform="linux/arm64" -f Dockerfile.init-multiarch-builder .
    rm Dockerfile.init-multiarch-builder
  EOT
}
