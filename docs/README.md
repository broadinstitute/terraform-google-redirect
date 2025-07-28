# terraform-google-redirect

Terraform module to build http/https redirects totally using GCP load balancer
components.

## Compatibility

This module is meant for use with Terraform 1.3+ and tested using Terraform
1.12. If you find incompatibilities using Terraform >=1.11, please open an
issue.

## Usage

```HCL
module "http_redirects" {
  source   = "github.com/broadinstitute/terraform-google-redirect//modules/http_redirects"

  default_destination_host       = var.default_destination_host
  default_destination_path       = var.default_destination_path
  default_redirect_response_code = var.default_redirect_response_code
  hostnames                      = var.hostnames
  name                           = var.name
  project                        = google_project.default.project_id
  redirects                      = var.redirects
  ssl_policy                     = google_compute_ssl_policy.default.self_link
}
```

* `default_destination_host`: The domain/hostname where any non-matching
requests should go.
* `default_destination_path`: The path under `default_destination_host`
where any non-matching requests should go.
* `hostnames`: A map of lists where each map is a certificate to be created,
with the value being the list of hostnames that should be in the certificate.
* `redirects`: A list of maps with any path-level redirects that should happen
under the provided hostnames. This field can be left blank (i.e. `[]`) which
will effectively redirect all the provided hostnames to the default host and
path. The fields within the map are:
  * `destination_host`: The host portion of the URL for the redirect
  * `destination_path`: The path portion of the URL for the redirect`
  * `redirect_response_code`: The HTTP code that should be used when doing a
  redirect.
  * `source_paths`: The list of paths under the source hostnames that should
  trigger a redirect. __Note: If you want to redirect a path ending with a
  slash (`/`) as well as one without a slash, you will need to make sure both
  paths are in the list.

<!-- BEGIN_TF_DOCS -->
## Terraform docs

[Terraform Docs](https://terraform-docs.io/) created by running the following
from the root of the repository:

```Shell
podman run --rm -u $(id -u) \
    --volume "$(pwd):/terraform-docs" \
    -w /terraform-docs \
    quay.io/terraform-docs/terraform-docs:latest \
    --output-file ../../docs/README.md \
    --output-mode inject /terraform-docs/modules/http_redirects
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6, < 7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6, < 7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificates"></a> [certificates](#module\_certificates) | ../certificates | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_global_address.public_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.global_forwarding_http_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.global_forwarding_https_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_target_http_proxy.http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_https_proxy.https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.http_to_https_redirect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_compute_url_map.https_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_destination_host"></a> [default\_destination\_host](#input\_default\_destination\_host) | The default host to redirect to if no paths are matched. | `string` | n/a | yes |
| <a name="input_default_destination_path"></a> [default\_destination\_path](#input\_default\_destination\_path) | The default path to redirect to if no paths are matched. | `string` | n/a | yes |
| <a name="input_hostnames"></a> [hostnames](#input\_hostnames) | A map of certificates to create, with the value being the list of hostnames | `map(list(string))` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The GCP project ID | `string` | n/a | yes |
| <a name="input_redirects"></a> [redirects](#input\_redirects) | The map of redirects to apply to the path under the hostname. | <pre>list(object({<br/>    destination_host       = string<br/>    destination_path       = string<br/>    redirect_response_code = string<br/>    source_paths           = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_default_redirect_response_code"></a> [default\_redirect\_response\_code](#input\_default\_redirect\_response\_code) | The default response code to use for redirects. | `string` | `"MOVED_PERMANENTLY_DEFAULT"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use for all resources created. | `string` | `null` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The SSL policy to use for the redirects. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_ip_address"></a> [load\_balancer\_ip\_address](#output\_load\_balancer\_ip\_address) | IP address of the HTTP Cloud Load Balancer |
<!-- END_TF_DOCS -->
