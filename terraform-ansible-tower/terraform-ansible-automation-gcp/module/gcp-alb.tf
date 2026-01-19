# Create a DNS authorization
resource "google_certificate_manager_dns_authorization" "dns_authorization" {
  name        = "${var.prefix}-dns-auth"
  location    = "global"
  domain      = "singhritesh85.com"
  type        = "PER_PROJECT_RECORD"   ###"FIXED_RECORD"
  description = "DNS authorization for singhritesh85.com"
}

# Create a Google-managed certificate
resource "google_certificate_manager_certificate" "gcp_certificate" {
  name        = "${var.prefix}-global-cert"
  location    = "global"
  scope       = "DEFAULT"   ###"ALL_REGIONS"

  managed {
    domains = ["*.singhritesh85.com"]   ###[google_certificate_manager_dns_authorization.dns_authorization.domain]
    dns_authorizations = [google_certificate_manager_dns_authorization.dns_authorization.id]
  }
}

# Create a certificate map
resource "google_certificate_manager_certificate_map" "gcp_certificate_map" {
  name        = "${var.prefix}-certificate-map"
  description = "Certificate map for *.singhritesh85.com"
}

# Create a certificate map entry
resource "google_certificate_manager_certificate_map_entry" "gcp_certificate_map_entry" {
  name          = "${var.prefix}-certificate-map-entry"
  map           = google_certificate_manager_certificate_map.gcp_certificate_map.name
  certificates  = [google_certificate_manager_certificate.gcp_certificate.id]
  hostname      = "*.singhritesh85.com"
}

# URL Map
resource "google_compute_url_map" "ansible_automation_urlmap" {
  name        = "${var.prefix}-urlmap"
  description = "${var.prefix} Routing Rules for GCP ALB"

  default_service = google_compute_backend_service.gcp_alb_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.gcp_alb_backend.id
  }

  test {
    service = google_compute_backend_service.gcp_alb_backend.id
    host    = "ansible-automation.singhritesh85.com"
    path    = "/"
  }
}

resource "google_compute_url_map" "http_redirect" {
  name  = "${var.prefix}-http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"  ### 301 redirect
    strip_query            = false
    https_redirect         = true  ### Redirection is happening
  }
}

resource "google_compute_instance_group" "ansible_automation_server" {
  name        = "ansible-automation-server-instance-group"
  description = "Instance Group for Ansible Automation Platform Server"
  zone        = data.google_compute_zones.available.names[1] ### For Ansible-Automation-Platform-Server VM Instance  ###"us-central1-a"

  instances   = google_compute_instance.vm_instance[*].id    ### [google_compute_instance.vm_instance[count.index].id]

  named_port {
    name = "ansible-automation"
    port = "443"
  }
}

resource "google_compute_backend_service" "gcp_alb_backend" {
  name    = "${var.prefix}-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol= "HTTPS"
 
  backend {
    group = google_compute_instance_group.ansible_automation_server.id
  }

  health_checks = [google_compute_health_check.https_health_check.id]
  port_name     = "ansible-automation"  ### The same name should appear in the instance groups referenced by this service.

  log_config {
    enable          = true
    optional_mode   = "CUSTOM"
    optional_fields = [ "orca_load_report", "tls.protocol" ]
  }
}

#resource "google_compute_http_health_check" "gcp_alb_health_check" {
#  name                = "${var.prefix}-healthcheck"
#  request_path        = "/api/v2/ping/"
#  port                = 443
#  check_interval_sec  = 5
#  timeout_sec         = 3
#  healthy_threshold   = 2
#  unhealthy_threshold = 2
#}

resource "google_compute_health_check" "https_health_check" {
  name = "https-health-check"

  timeout_sec        = 3
  check_interval_sec = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  https_health_check {
    port_name    = "ansible-automation"
    port         = "443"
    request_path = "/api/v2/ping/"
  }
}

resource "google_compute_global_address" "alb_static_ip" {
  name         = "${var.prefix}-static-ip"
  address_type = "EXTERNAL"
  description  = "Static IP for the GCP ALB"
}

resource "google_compute_global_forwarding_rule" "lb_frontend_https" {
  name                  = "${var.prefix}-lb-frontend-https"
  target                = google_compute_target_https_proxy.gcp_target_https_proxy.id
  port_range            = "443"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.alb_static_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"
}

resource "google_compute_global_forwarding_rule" "lb_frontend_http" {
  name                  = "${var.prefix}-lb-frontend-http"
  target                = google_compute_target_http_proxy.gcp_target_http_proxy.id
  port_range            = "80"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.alb_static_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"
}

resource "google_compute_target_https_proxy" "gcp_target_https_proxy" {
  name             = "${var.prefix}-https-proxy"
  url_map          = google_compute_url_map.ansible_automation_urlmap.id
  certificate_map  = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.gcp_certificate_map.id}"
}

resource "google_compute_target_http_proxy" "gcp_target_http_proxy" {
  name             = "${var.prefix}-http-proxy"
  url_map          = google_compute_url_map.http_redirect.id
}
