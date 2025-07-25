locals {
  cert_map  = { "${var.hostnames[0]}" = var.hostnames }
  safe_name = var.name != null ? var.name : replace(var.hostnames[0], ".", "-")
}

# resource "google_compute_managed_ssl_certificate" "certificate" {
#   name     = "${local.safe_name}-managed-certificate"
#   provider = google

#   managed {
#     domains = var.hostnames
#   }
# }

module "path_certificates" {
  source   = "../certificates"

  certificates = local.cert_map
  name         = local.safe_name
}

resource "google_compute_url_map" "https_url_map" {
  name = "${local.safe_name}-https-url-map"

  default_url_redirect {
    host_redirect          = var.default_destination_host
    path_redirect          = var.default_destination_path
    redirect_response_code = "TEMPORARY_REDIRECT"
    strip_query            = false
  }

  host_rule {
    hosts        = var.hostnames
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"

    default_url_redirect {
      host_redirect          = var.default_destination_host
      path_redirect          = var.default_destination_path
      redirect_response_code = "TEMPORARY_REDIRECT"
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
  certificate_map  = module.path_certificates.certificate_map.id
  name             = "${local.safe_name}-https-proxy"
  ssl_policy       = var.ssl_policy
  url_map          = google_compute_url_map.https_url_map.self_link
}

resource "google_compute_url_map" "http_to_https_redirect" {
  name = "${local.safe_name}-to-http-url-map"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${local.safe_name}-http-proxy"
  url_map = google_compute_url_map.http_to_https_redirect.self_link
}

resource "google_compute_global_address" "public_address" {
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  name         = "${local.safe_name}-public-address"
}

resource "google_compute_global_forwarding_rule" "global_forwarding_https_rule" {
  ip_address = google_compute_global_address.public_address.address
  name       = "${local.safe_name}-global-forwarding-https-rule"
  port_range = "443"
  target     = google_compute_target_https_proxy.https_proxy.self_link
}

resource "google_compute_global_forwarding_rule" "global_forwarding_http_rule" {
  ip_address = google_compute_global_address.public_address.address
  name       = "${local.safe_name}-global-forwarding-http-rule"
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy.self_link
}
