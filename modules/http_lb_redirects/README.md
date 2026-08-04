# http_lb_redirects

Terraform module to build http/https redirects totally using GCP load balancer
components.

Unlike [`http_redirects`](../http_redirects), which manages a single set of
hostnames behind one certificate, this module fronts **multiple, independent
groups of hostnames** with a single shared load balancer (one public IP, one
HTTP proxy, one HTTPS proxy). Each group in `redirects` gets its own
certificate(s), its own default destination, and its own path-level redirects,
routed via one `google_compute_url_map` with one `path_matcher` per group.

## Compatibility

This module is meant for use with Terraform 1.3+ and tested using Terraform
1.12. If you find incompatibilities using Terraform >=1.11, please open an
issue.

## Usage

```hcl
resource "google_certificate_manager_dns_authorization" "redirects" {
  for_each = toset(["example.org", "www.example.org", "example.net"])

  domain  = each.key
  name    = replace(each.key, ".", "-")
  project = google_project.default.project_id
  type    = "PER_PROJECT_RECORD"
}

module "http_lb_redirects" {
  source = "github.com/broadinstitute/terraform-google-redirect//modules/http_lb_redirects"

  name                     = "example-redirects"
  project                  = google_project.default.project_id
  default_destination_host = "www.broadinstitute.org"
  default_destination_path = "/"
  ssl_policy               = google_compute_ssl_policy.default.self_link
  dns_authorizations       = google_certificate_manager_dns_authorization.redirects

  redirects = {
    "example-org" = {
      certificates = {
        "example-org" = ["example.org", "www.example.org"]
      }
      default_destination_host = "www.example.org"
      default_destination_path = "/"
      redirects = [
        {
          destination_host = "docs.example.org"
          destination_path = "/getting-started/"
          source_paths     = ["/docs", "/docs/"]
        },
      ]
    }

    "example-net" = {
      certificates = {
        "example-net" = ["example.net"]
      }
      default_destination_host = "www.example.net"
      redirects                = []
    }
  }
}
```

Point the DNS records for every hostname referenced above (both in
`redirects.*.certificates` and in `dns_authorizations`) at the module's
`load_balancer_ip_address` output.

### Top-level arguments

- `name`: Prefix used for the name of every resource this module creates.
- `project`: The GCP project ID to create resources in.
- `default_destination_host` / `default_destination_path` /
  `default_redirect_response_code`: Where to send a request whose `Host` header
  doesn't match any hostname configured in `redirects`.
- `ssl_policy`: Optional SSL policy `self_link` to attach to the HTTPS proxy.
- `dns_authorizations`: Map of `google_certificate_manager_dns_authorization`
  resources, keyed by hostname, used to prove domain ownership when
  `use_dns_authorizations` is `true`. Pass `{}` and set
  `use_dns_authorizations = false` per-group to request certificates without DNS
  authorization.
- `http_port_range` / `https_port_range`: Ports the shared forwarding rules
  listen on.

### `redirects`

A map where each key is an arbitrary group name (used as the GCP `path_matcher`
name, so it must match `^[a-z][a-z0-9-]*$`) and each value describes one
independent set of hostnames sharing certificate(s) and a redirect policy:

- `certificates`: A map of certificate name to the list of hostnames that
  certificate should cover, e.g.
  `{ "example-org" = ["example.org", "www.example.org"] }`. Every hostname
  listed here is added as a `host_rule` routed to this group.
- `default_destination_host` / `default_destination_path` /
  `default_redirect_response_code`: Where to send a request that matches one of
  this group's hostnames but no entry in this group's `redirects` below.
- `redirects`: A list of path-level redirects to apply within this group. Can be
  `[]`, which redirects every request for this group's hostnames to its
  `default_destination_host`/`default_destination_path`. Each entry has:
  - `destination_host`: The host portion of the redirect target.
  - `destination_path`: The path portion of the redirect target.
  - `redirect_response_code`: The HTTP status code to use for the redirect
    (defaults to `MOVED_PERMANENTLY_DEFAULT`).
  - `source_paths`: The list of paths under this group's hostnames that trigger
    this redirect. **Note:** if you want a path to match with and without a
    trailing slash (`/path` and `/path/`), both must be listed.
- `use_dns_authorizations`: Whether to use `dns_authorizations` for this group's
  certificates (defaults to `true`).

<!-- BEGIN_TF_DOCS -->

## Terraform docs

[Terraform Docs](https://terraform-docs.io/) created by running the following
from the root of the repository:

```shell
podman run --rm -u $(id -u) \
    --volume "$(pwd):/terraform-docs" \
    -w /terraform-docs \
    quay.io/terraform-docs/terraform-docs:latest \
    --output-file README.md \
    --output-mode inject /terraform-docs/modules/http_lb_redirects
```

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.10   |
| <a name="requirement_google"></a> [google](#requirement_google)          | >= 6, < 8 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 3.4    |

## Providers

| Name                                                      | Version   |
| --------------------------------------------------------- | --------- |
| <a name="provider_google"></a> [google](#provider_google) | >= 6, < 8 |
| <a name="provider_random"></a> [random](#provider_random) | >= 3.4    |

## Modules

| Name                                                                    | Source          | Version |
| ----------------------------------------------------------------------- | --------------- | ------- |
| <a name="module_certificates"></a> [certificates](#module_certificates) | ../certificates | n/a     |

## Resources

| Name                                                                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [google_certificate_manager_certificate_map.redirects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map)          | resource |
| [google_compute_global_address.public_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address)                               | resource |
| [google_compute_global_forwarding_rule.global_forwarding_http_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule)  | resource |
| [google_compute_global_forwarding_rule.global_forwarding_https_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_target_http_proxy.http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy)                             | resource |
| [google_compute_target_https_proxy.https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy)                          | resource |
| [google_compute_url_map.http_to_https_redirect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map)                                     | resource |
| [google_compute_url_map.https_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map)                                              | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                               | resource |

## Inputs

| Name                                                                                                                           | Description                                                                  | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Default                       | Required |
| ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | :------: |
| <a name="input_default_destination_host"></a> [default\_destination\_host](#input_default_destination_host)                    | The default host to redirect to if no paths are matched                      | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | n/a                           |   yes    |
| <a name="input_default_destination_path"></a> [default\_destination\_path](#input_default_destination_path)                    | The default path to redirect to if no paths are matched                      | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | n/a                           |   yes    |
| <a name="input_name"></a> [name](#input_name)                                                                                  | The name to use for all resources created                                    | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | n/a                           |   yes    |
| <a name="input_project"></a> [project](#input_project)                                                                         | The GCP project ID                                                           | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | n/a                           |   yes    |
| <a name="input_redirects"></a> [redirects](#input_redirects)                                                                   | The map of redirects to create.                                              | <pre>map(object({<br/> certificates = map(list(string))<br/> default_destination_host = optional(string, "www.broadinstitute.org")<br/> default_destination_path = optional(string, "/")<br/> default_redirect_response_code = optional(string, "MOVED_PERMANENTLY_DEFAULT")<br/> http_port_range = optional(string, "80")<br/> https_port_range = optional(string, "443")<br/> redirects = list(object({<br/> destination_host = string<br/> destination_path = optional(string)<br/> redirect_response_code = optional(string, "MOVED_PERMANENTLY_DEFAULT")<br/> source_paths = list(string)<br/> }))<br/> use_dns_authorizations = optional(bool, true)<br/> }))</pre> | n/a                           |   yes    |
| <a name="input_default_redirect_response_code"></a> [default\_redirect\_response\_code](#input_default_redirect_response_code) | The default response code to use for redirects                               | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `"MOVED_PERMANENTLY_DEFAULT"` |    no    |
| <a name="input_dns_authorizations"></a> [dns\_authorizations](#input_dns_authorizations)                                       | A map of DNS authorizations to use, with the key being the domain authorized | `map(any)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | `{}`                          |    no    |
| <a name="input_http_port_range"></a> [http\_port\_range](#input_http_port_range)                                               | A range of HTTP ports on which to listen                                     | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `"80"`                        |    no    |
| <a name="input_https_port_range"></a> [https\_port\_range](#input_https_port_range)                                            | A range of HTTPS ports on which to listen                                    | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `"443"`                       |    no    |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input_ssl_policy)                                                               | The SSL policy to use for the redirects                                      | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `null`                        |    no    |
| <a name="input_use_dns_authorizations"></a> [use\_dns\_authorizations](#input_use_dns_authorizations)                          | Whether to use DNS authorizations for hostname verification                  | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `true`                        |    no    |

## Outputs

| Name                                                                                                           | Description                                |
| -------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| <a name="output_load_balancer_ip_address"></a> [load\_balancer\_ip\_address](#output_load_balancer_ip_address) | IP address of the HTTP Cloud Load Balancer |

<!-- END_TF_DOCS -->
