resource "google_certificate_manager_certificate_map" "default" {
  name        = "redirect-${var.name}"
  description = "Certificate map for ${var.name}"
  labels      = {
    "terraform" : true,
    "acc-test"  : true,
  }
}

resource "google_certificate_manager_certificate_map_entry" "default" {
  for_each = var.certificates

  certificates = [google_certificate_manager_certificate.default[each.key].id]
  description  = "Certificate map entry for ${each.key}"
  map          = google_certificate_manager_certificate_map.default.name
  matcher      = "PRIMARY"
  name         = format("redirect-%s", replace(each.key, ".", "-"))

  labels      = {
    "terraform" : true,
    "acc-test"  : true,
  }
}

resource "google_certificate_manager_certificate" "default" {
  for_each = var.certificates

  description = "Certificate for ${each.key}"
  name        = format("redirect-%s", replace(each.key, ".", "-"))
  scope       = "DEFAULT"

  managed {
    domains = each.value
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
