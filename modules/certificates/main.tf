
resource "google_certificate_manager_certificate_map" "certificates" {
  description = "Certificate map for ${var.name}"
  name        = "${var.name}-${var.suffix}"
  project     = var.project

  labels = {
    "terraform" : true,
    "acc-test" : true,
  }
}

resource "google_certificate_manager_certificate_map_entry" "certificates" {
  for_each = transpose(var.certificates)

  certificates = [google_certificate_manager_certificate.certificates[each.value[0]].id]
  description  = "Certificate map entry for ${each.value[0]}"
  map          = google_certificate_manager_certificate_map.certificates.name
  hostname     = each.key
  name         = format("%s-%s", replace(each.key, ".", "-"), var.suffix)
  project      = var.project

  labels = {
    "terraform" : true,
    "acc-test" : true,
  }
}

resource "google_certificate_manager_certificate" "certificates" {
  for_each = var.certificates

  description = "Certificate for ${each.key}"
  name        = format("%s-%s", replace(each.key, ".", "-"), var.suffix)
  project     = var.project
  scope       = "DEFAULT"

  managed {
    dns_authorizations = var.use_dns_authorizations ? [for hostname in each.value : var.dns_authorizations[hostname].id] : []
    domains            = each.value
  }
}
