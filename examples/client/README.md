A basic example to launched the two remote builders (TLS) in order to use them for building amd64 and arm64 container builders in the client using [buildx](https://github.com/docker/buildx). `create_client_certs` and `handle_client_config` input variables are set to `true` for automatic [buildx](https://github.com/docker/buildx) configuration in the client.


## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan -input
terraform apply -input
```
