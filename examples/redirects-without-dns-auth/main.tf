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

module "http_redirects" {
  source = "github.com/broadinstitute/terraform-google-redirect//modules/http_redirects?ref=tex/dnsauth"

  certificates = {
    "example.org" = ["example.org", "www.example.org"]
  }
  default_destination_host = "www.example.com"
  default_destination_path = "/"
  dns_authorizations       = {}
  name                     = "example-org"
  project                  = data.google_project.redirects.project_id
  redirects = [
    {
      destination_host = "web.example.org"
      destination_path = "/otherpath/"
      source_paths     = ["/somepath", "/somepath/"]
    },
  ]
  ssl_policy             = google_compute_ssl_policy.redirects.self_link
  use_dns_authorizations = false
}
