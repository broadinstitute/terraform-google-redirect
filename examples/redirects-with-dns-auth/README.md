# Redirects Using DNS Authorization Records

This example shows how to call the `http_redirects` module while using
[certificate_manager_dns_authorization](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization)
resources. This is the preferred method as it allows the certificates for the
load balancer(s) to be created before the final DNS changes have been made to
point traffic at the new infrastructure. The wait time for certificates to be
created is also typically much shorter with this method.

Be aware that if you use DNS authorization records, the object you pass to the
`http_redirects` module for `dns_authorizations` must contain authorizations for
all of the hostnames used by your redirects **and** must be a map of
`certificate_manager_dns_authorization` records indexed by those hostnames.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.10   |
| <a name="requirement_google"></a> [google](#requirement_google)          | >= 6, < 7 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 3.4    |

## Providers

| Name                                                      | Version   |
| --------------------------------------------------------- | --------- |
| <a name="provider_google"></a> [google](#provider_google) | >= 6, < 7 |

## Modules

| Name                                                                          | Source                                                                      | Version     |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ----------- |
| <a name="module_http_redirects"></a> [http_redirects](#module_http_redirects) | github.com/broadinstitute/terraform-google-redirect//modules/http_redirects | tex/dnsauth |

## Resources

| Name                                                                                                                                                                           | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [google_certificate_manager_dns_authorization.redirects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization) | resource    |
| [google_compute_ssl_policy.redirects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy)                                       | resource    |
| [google_project.redirects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project)                                                          | data source |

## Inputs

| Name                                                            | Description | Type     | Default | Required |
| --------------------------------------------------------------- | ----------- | -------- | ------- | :------: |
| <a name="input_project_id"></a> [project_id](#input_project_id) | n/a         | `string` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
