# certificates

This submodule handles creating all certificate components used by the
redirects. The design uses GCP
[Certificate Manager](https://cloud.google.com/certificate-manager/docs/overview)
to create all certificates.

## Usage

```hcl
module "certificates" {
  source   = "github.com/broadinstitute/terraform-google-redirect//modules/certificates"

  certificates = var.hostnames
  name         = var.name
}
```

- `name`: The name used as a suffix for all certificate resources created in
  GCP.
- `certificates`:

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
    --output-mode inject /terraform-docs/modules/certificates
```

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.10   |
| <a name="requirement_google"></a> [google](#requirement_google)          | >= 6, < 8 |

## Providers

| Name                                                      | Version   |
| --------------------------------------------------------- | --------- |
| <a name="provider_google"></a> [google](#provider_google) | >= 6, < 8 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                      | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [google_certificate_manager_certificate.certificates](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate)                     | resource |
| [google_certificate_manager_certificate_map.certificates](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map)             | resource |
| [google_certificate_manager_certificate_map_entry.certificates](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource |

## Inputs

| Name                                                                                                | Description                                                                  | Type                | Default | Required |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ------------------- | ------- | :------: |
| <a name="input_certificates"></a> [certificates](#input_certificates)                               | A map of certificates to create                                              | `map(list(string))` | n/a     |   yes    |
| <a name="input_project"></a> [project](#input_project)                                              | The GCP project ID                                                           | `string`            | n/a     |   yes    |
| <a name="input_suffix"></a> [suffix](#input_suffix)                                                 | A suffix to append to all resource names                                     | `string`            | n/a     |   yes    |
| <a name="input_dns_authorizations"></a> [dns_authorizations](#input_dns_authorizations)             | A map of DNS authorizations to use, with the key being the domain authorized | `map(any)`          | `{}`    |    no    |
| <a name="input_name"></a> [name](#input_name)                                                       | The name to use for all resources created.                                   | `string`            | `null`  |    no    |
| <a name="input_use_dns_authorizations"></a> [use_dns_authorizations](#input_use_dns_authorizations) | Whether to use DNS authorizations for hostname verification                  | `bool`              | `true`  |    no    |

## Outputs

| Name                                                                             | Description                            |
| -------------------------------------------------------------------------------- | -------------------------------------- |
| <a name="output_certificate_map"></a> [certificate_map](#output_certificate_map) | Certificate map created by this module |

<!-- END_TF_DOCS -->
