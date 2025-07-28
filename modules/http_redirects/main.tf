locals {
  all_hosts = flatten([for cert, hosts in var.certificates : hosts])
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "certificates" {
  source = "../certificates"

  certificates           = var.certificates
  dns_authorizations     = var.dns_authorizations
  name                   = var.name
  project                = var.project
  suffix                 = random_id.suffix.hex
  use_dns_authorizations = var.use_dns_authorizations
}

resource "google_compute_url_map" "https_url_map" {
  name    = "${var.name}-https-${random_id.suffix.hex}"
  project = var.project

  default_url_redirect {
    host_redirect          = var.default_destination_host
    path_redirect          = var.default_destination_path
    redirect_response_code = var.default_redirect_response_code
    strip_query            = false
  }

  host_rule {
    hosts        = local.all_hosts
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"

    default_url_redirect {
      host_redirect          = var.default_destination_host
      path_redirect          = var.default_destination_path
      redirect_response_code = var.default_redirect_response_code
      strip_query            = false
    }

    dynamic "path_rule" {
      for_each = var.redirects
      iterator = rule

      content {
        paths = rule.value.source_paths

        url_redirect {
          https_redirect         = true
          host_redirect          = rule.value.destination_host
          path_redirect          = rule.value.destination_path
          redirect_response_code = rule.value.redirect_response_code
          strip_query            = false
        }
      }
    }
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  certificate_map = "//certificatemanager.googleapis.com/${module.certificates.certificate_map.id}"
  name            = "${var.name}-https-${random_id.suffix.hex}"
  project         = var.project
  ssl_policy      = var.ssl_policy
  url_map         = google_compute_url_map.https_url_map.self_link
}

resource "google_compute_url_map" "http_to_https_redirect" {
  name    = "${var.name}-http-${random_id.suffix.hex}"
  project = var.project

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.name}-http-${random_id.suffix.hex}"
  project = var.project
  url_map = google_compute_url_map.http_to_https_redirect.self_link
}

resource "google_compute_global_address" "public_address" {
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  name         = "${var.name}-${random_id.suffix.hex}"
  project      = var.project
}

resource "google_compute_global_forwarding_rule" "global_forwarding_https_rule" {
  ip_address = google_compute_global_address.public_address.address
  name       = "${var.name}-https-${random_id.suffix.hex}"
  port_range = var.https_port_range
  project    = var.project
  target     = google_compute_target_https_proxy.https_proxy.self_link
}

resource "google_compute_global_forwarding_rule" "global_forwarding_http_rule" {
  ip_address = google_compute_global_address.public_address.address
  name       = "${var.name}-http-${random_id.suffix.hex}"
  port_range = var.http_port_range
  project    = var.project
  target     = google_compute_target_http_proxy.http_proxy.self_link
}
