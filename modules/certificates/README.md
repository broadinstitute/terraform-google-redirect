# certificates

This submodule handles creating all certificate components used by the
redirects. The design uses GCP
[Certificate Manager](https://cloud.google.com/certificate-manager/docs/overview)
to create all certificates.

## Usage

```HCL
module "certificates" {
  source   = "github.com/broadinstitute/terraform-google-redirect//modules/certificates"

  certificates = var.hostnames
  name         = var.name
}
```

* `name`: The name used as a suffix for all certificate resources created in
GCP.
* `certificates`:

<!-- BEGIN_TF_DOCS -->
## Terraform docs

[Terraform Docs](https://terraform-docs.io/) created by running the following
from the root of the repository:

```Shell
podman run --rm -u $(id -u) \
    --volume "$(pwd):/terraform-docs" \
    -w /terraform-docs \
    quay.io/terraform-docs/terraform-docs:latest \
    --output-file README.md \
    --output-mode inject /terraform-docs/modules/certificates
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

No modules.

## Resources

| Name | Type |
|------|------|
| [google_certificate_manager_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate) | resource |
| [google_certificate_manager_certificate_map.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map) | resource |
| [google_certificate_manager_certificate_map_entry.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificates"></a> [certificates](#input\_certificates) | The list of certificates to create, with each element being a list of hostnames. | `map(list(string))` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to use for all resources created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_map"></a> [certificate\_map](#output\_certificate\_map) | Certificate map created by this module |
<!-- END_TF_DOCS -->