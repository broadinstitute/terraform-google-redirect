output "load_balancer_ip_address" {
  description = "IP address of the HTTP Cloud Load Balancer"
  value       = google_compute_global_address.public_address.address
}
