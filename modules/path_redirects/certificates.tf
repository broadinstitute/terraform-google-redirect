resource "google_compute_managed_ssl_certificate" "certificate" {
  name     = "${local.safe_name}-managed-certificate"
  provider = google

  managed {
    domains = var.hostnames
  }
}

# resource "google_certificate_manager_certificate_map" "default" {
#   name        = "${local.safe_name}-path"
#   description = "Certificate map for ${local.safe_name}"
#   labels      = {
#     "terraform" : true,
#     "acc-test"  : true,
#   }
# }

# resource "google_certificate_manager_certificate_map_entry" "default" {
#   for_each = toset(var.hostnames)

#   certificates = [google_certificate_manager_certificate.certificate.id]
#   description  = "Certificate map entry for ${each.key}"
#   map          = google_certificate_manager_certificate_map.default.name
#   matcher      = "PRIMARY"
#   name         = format("%s-path", replace(each.key, ".", "-"))

#   labels      = {
#     "terraform" : true,
#     "acc-test"  : true,
#   }
# }

resource "google_certificate_manager_certificate" "default" {
  for_each = toset(var.hostnames)

  description = "Certificate for ${each.key}"
  name        = format("%s-path", replace(each.key, ".", "-"))
  scope       = "DEFAULT"

  managed {
    domains = [for cert in google_certificate_manager_dns_authorization.default : cert.domain]
    dns_authorizations = [for cert in google_certificate_manager_dns_authorization.default : cert.id]
    # domains = google_certificate_manager_dns_authorization.default[*].domain
    # dns_authorizations = google_certificate_manager_dns_authorization.default[*].id
    # domains = [
    #   google_certificate_manager_dns_authorization.default.domain,
    #   google_certificate_manager_dns_authorization.instance2.domain,
    #   ]
    # dns_authorizations = [
    #   google_certificate_manager_dns_authorization.default.id,
    #   google_certificate_manager_dns_authorization.instance2.id,
    #   ]
  }
}

resource "google_certificate_manager_dns_authorization" "default" {
  for_each = toset(var.hostnames)

  description = "DNS authorization for ${each.key}"
  domain      = each.key
  name        = format("%s-path", replace(each.key, ".", "-"))
}
