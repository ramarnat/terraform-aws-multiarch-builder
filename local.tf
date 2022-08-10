locals {
  client_config_amd64_cmd = try(<<-EOT
    set -eu
    # vars
    unset DOCKER_HOST
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH='${pathexpand(var.docker_cert_path)}'
    # cleanup first
    docker context use default || echo "ignoring error..."
    docker context rm multiarch-builder-amd64 || echo "ignoring error..."
    %{if !var.create_arm64~}
    docker context rm multiarch-builder-arm64 || echo "ignoring error..."
    %{endif~}
    docker buildx use default || echo "ignoring error..."
    docker buildx create --leave --name multiarch-builder --node multiarch-builder-amd64 || echo "ignoring error..."
    # config
    echo "about to set up client config for amd64 instance..."
    docker context create \
        %{if can(aws_route53_record.aws-multiarch-builder-amd64[0])~}
        --docker host=tcp://${aws_route53_record.aws-multiarch-builder-amd64[0].fqdn}:2376,ca="${pathexpand(var.docker_cert_path)}/ca.pem",cert="${pathexpand(var.docker_cert_path)}/cert.pem",key="${pathexpand(var.docker_cert_path)}/key.pem" \
        %{else~}
        --docker host=tcp://${aws_spot_instance_request.multiarch_builder_amd64[0].public_dns}:2376,ca="${pathexpand(var.docker_cert_path)}/ca.pem",cert="${pathexpand(var.docker_cert_path)}/cert.pem",key="${pathexpand(var.docker_cert_path)}/key.pem" \
        %{endif~}
        --description "Remote amd64 builder for multiarch-builder instance" \
        multiarch-builder-amd64
    ## use context and wait for initial startup
    echo "about to set up docker context 'multiarch-builder-amd64'..."
    docker context use multiarch-builder-amd64
    timeout 120 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for multiarch-builder-amd64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    ## set buildx builder amd64 instance
    echo "about to set up buildx node 'multiarch-builder-amd64'..."
    docker buildx create --use --bootstrap --append --name multiarch-builder \
        --driver docker-container \
        --platform linux/amd64 \
        --node=multiarch-builder-amd64 \
        multiarch-builder-amd64
  EOT
  , "")
  client_config_arm64_cmd = try(<<-EOT
    set -eu
    # vars
    unset DOCKER_HOST
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH='${pathexpand(var.docker_cert_path)}'
    # cleanup first
    docker context use default || echo "ignoring error..."
    docker context rm multiarch-builder-arm64 || echo "ignoring error..."
    %{if !var.create_amd64~}
    docker context rm multiarch-builder-amd64 || echo "ignoring error..."
    %{endif~}
    docker buildx use default || echo "ignoring error..."
    docker buildx create --leave --name multiarch-builder --node multiarch-builder-arm64 || echo "ignoring error..."
    # config
    echo "about to set up client config for arm64 instance..."
    docker context create \
        %{if can(aws_route53_record.aws-multiarch-builder-arm64[0])~}
        --docker host=tcp://${aws_route53_record.aws-multiarch-builder-arm64[0].fqdn}:2376,ca="${pathexpand(var.docker_cert_path)}/ca.pem",cert="${pathexpand(var.docker_cert_path)}/cert.pem",key="${pathexpand(var.docker_cert_path)}/key.pem" \
        %{else~}
        --docker host=tcp://${aws_spot_instance_request.multiarch_builder_arm64[0].public_dns}:2376,ca="${pathexpand(var.docker_cert_path)}/ca.pem",cert="${pathexpand(var.docker_cert_path)}/cert.pem",key="${pathexpand(var.docker_cert_path)}/key.pem" \
        %{endif~}
        --description "Remote arm64 builder for multiarch-builder instance" \
        multiarch-builder-arm64
    ## use context and wait for initial startup
    echo "about to set up docker context 'multiarch-builder-arm64'..."
    docker context use multiarch-builder-arm64
    timeout 120 bash -c "until docker info &>/dev/null; do sleep 1; echo 'waiting for multiarch-builder-arm64 connection...'; done" || { echo "timeout waiting for remote"; exit 1; }
    ## set buildx builder arm64 instance
    echo "about to set up buildx node 'multiarch-builder-arm64'..."
    docker buildx create --use --bootstrap --append --name multiarch-builder \
        --driver docker-container \
        --platform linux/arm64 \
        --node=multiarch-builder-arm64 \
        multiarch-builder-arm64
  EOT
  , "")
}
