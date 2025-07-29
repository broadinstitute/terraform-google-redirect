locals {
  all_hosts = ["example.org", "www.example.org"]
}

data "google_project" "redirects" {
  project_id = var.project_id
}

resource "google_compute_ssl_policy" "redirects" {
  description     = "TLS policy for redirects"
  min_tls_version = "TLS_1_2"
  name            = "redirects-tls-policy"
  profile         = "MODERN"
  project         = data.google_project.redirects.project_id
}

resource "google_certificate_manager_dns_authorization" "redirects" {
  for_each = toset(local.all_hosts)

  description = "DNS authorization for ${each.key}"
  domain      = each.key
  name        = replace(each.key, ".", "-")
  project     = data.google_project.redirects.project_id
  type        = "PER_PROJECT_RECORD"
}

module "http_redirects" {
  source = "github.com/broadinstitute/terraform-google-redirect//modules/http_redirects?ref=tex/dnsauth"

  certificates = {
    "example.org" = local.all_hosts
  }
  default_destination_host = "www.example.com"
  default_destination_path = "/"
  dns_authorizations       = google_certificate_manager_dns_authorization.redirects
  name                     = "example-org"
  project                  = data.google_project.redirects.project_id
  redirects = [
    {
      destination_host = "web.example.org"
      destination_path = "/otherpath/"
      source_paths     = ["/somepath", "/somepath/"]
    },
  ]
  ssl_policy = google_compute_ssl_policy.redirects.self_link
}
