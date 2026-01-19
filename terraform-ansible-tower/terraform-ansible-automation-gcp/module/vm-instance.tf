############################################################ Service Account in GCP #############################################################

resource "google_service_account" "bankapp_sa" {
  account_id   = "${var.prefix}-sa"
  display_name = "${var.prefix} Service Account"
}

############################################ Reserver Internal IP Address for GCP VM Instance ###################################################

resource "google_compute_address" "instance_internal_ip" {
  count        = var.instance_count
  name         = "${var.prefix}-instance-internal-ip-${count.index + 1}"
  description  = "Internal IP address reserved for VM Instance"
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = google_compute_subnetwork.gcp_public_subnet.id 
  address      = "172.20.0.${100 + count.index}"
}

############################################# Create a single Compute Engine VM instance ########################################################

resource "google_compute_address" "vm_static_ip" {
  count        = var.instance_count
  name         = "ansible-automation-static-ip-${count.index + 1}"
  address_type = "EXTERNAL"
  region       = var.gcp_region  ###"us-central1"  # Replace with your desired region
  ip_version   = "IPV4"         # Default value is IPV4
}

data "google_compute_zones" "available" {
  region  = var.gcp_region
}

resource "google_compute_instance" "vm_instance" {
  count        = var.instance_count
  name         = "${var.prefix}-vm-instance-${count.index + 1}"
  machine_type = var.machine_type
  zone         = data.google_compute_zones.available.names[1]   ###"us-central1-a"
  boot_disk {
    initialize_params {
      image = "rhel-9-v20260114"
      size  = 30
      type  = "pd-standard" ### Select among pd-standard, pd-balanced or pd-ssd.
      architecture = "X86_64"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.gcp_public_subnet.id
    network_ip = google_compute_address.instance_internal_ip[count.index].address
    access_config {
      nat_ip = google_compute_address.vm_static_ip[count.index].address   ### Static IP Assigned to GCP VM Instance.
    }
  }
  service_account {
    email = google_service_account.bankapp_sa.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = file("startup-ansible-automation.sh")

  tags = ["allow-ssh", "allow-health-check", "allow-receptor-service"]
}
