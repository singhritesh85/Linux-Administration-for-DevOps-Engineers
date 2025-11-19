# Service Account in GCP
resource "google_service_account" "bankapp_sa" {
  account_id   = "${var.prefix}-sa"
  display_name = "${var.prefix} Service Account"
}

############################################ Reserver Internal IP Address for GCP VM Instance ###################################################

resource "google_compute_address" "instance_internal_ip" {
  count        = 2
  name         = "${var.prefix}-instance-internal-ip-${count.index + 1}"
  description  = "Internal IP address reserved for VM Instance"
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = google_compute_subnetwork.gcp_public_subnet.id 
  address      = "172.20.0.${100 + count.index}"
}

############################################# Create a single Compute Engine VM instance ########################################################

resource "google_compute_address" "vm_static_ip" {
  count        = 2
  name         = "gitlab-runner-static-ip-${count.index + 1}"
  address_type = "EXTERNAL"
  region       = "us-central1"  # Replace with your desired region
  ip_version   = "IPV4"         # Default value is IPV4
}

resource "google_compute_instance" "vm_instance" {
  count        = 2
  name         = "${var.prefix}-vm-instance-${count.index + 1}"
  machine_type = var.machine_type
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = count.index == 0 ? "rhel-9-v20251111" : "rocky-linux-8-v20251113"
      size  = 20
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
  metadata_startup_script = count.index == 0 ? file("startup-oscap-rhel9.sh") : file("startup-oscap-rockeylinux8.sh")

  tags = ["allow-ssh"]
}

###################################### Reserver Internal IP Address for GCP VM Instance for httpd webserver #############################################

resource "google_compute_address" "instance_internal_ip_httpd" {
  name         = "${var.prefix}-httpd-instance-internal-ip"
  description  = "Internal IP address reserved for VM Instance of httpd"
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = google_compute_subnetwork.gcp_public_subnet.id
  address      = "172.20.0.103"
}

###################################### Create a single Compute Engine VM instance for httpd webserver ##################################################

resource "google_compute_address" "vm_static_ip_httpd" {
  name         = "httpd-static-ip"
  address_type = "EXTERNAL"
  region       = "us-central1"  # Replace with your desired region
  ip_version   = "IPV4"         # Default value is IPV4
}

resource "google_compute_instance" "vm_instance-httpd" {
  name         = "webserver"
  machine_type = var.machine_type
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "rocky-linux-8-v20250610"
      size  = 20
      type  = "pd-standard" ### Select among pd-standard, pd-balanced or pd-ssd.
      architecture = "X86_64"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.gcp_public_subnet.id
    network_ip = google_compute_address.instance_internal_ip_httpd.address
    access_config {
      nat_ip = google_compute_address.vm_static_ip_httpd.address   ### Static IP Assigned to GCP VM Instance.
    }
  }
  service_account {
    email = google_service_account.bankapp_sa.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = file("startup-httpd.sh")

  tags = ["allow-ssh", "allow-health-check"]
}

##################################### Reserver Internal IP Address for GCP VM Instance for Ansible Controller ######################################

resource "google_compute_address" "instance_internal_ip_ansible" {
  name         = "${var.prefix}-instance-internal-ip-ansible"
  description  = "Internal IP address reserved for VM Instance"
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = google_compute_subnetwork.gcp_public_subnet.id
  address      = "172.20.0.104"
}

###################################### Create a single Compute Engine VM instance for Ansible Controller ###########################################

resource "google_compute_address" "vm_static_ip_ansible" {
  name         = "ansible-static-ip"
  address_type = "EXTERNAL"
  region       = "us-central1"  # Replace with your desired region
  ip_version   = "IPV4"         # Default value is IPV4
}

resource "google_compute_instance" "vm_instance_ansible" {
  name         = "ansible-controller"
  machine_type = var.machine_type
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "rocky-linux-8-v20250610"
      size  = 20
      type  = "pd-standard" ### Select among pd-standard, pd-balanced or pd-ssd.
      architecture = "X86_64"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.gcp_public_subnet.id
    network_ip = google_compute_address.instance_internal_ip_ansible.address
    access_config {
      nat_ip = google_compute_address.vm_static_ip_ansible.address   ### Static IP Assigned to GCP VM Instance.
    }
  }
  service_account {
    email = google_service_account.bankapp_sa.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = file("startup-ansible.sh")

  tags = ["allow-ssh"]
}
