terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {

  project = "vadaszgergo"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet01" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.10.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "vm_instance_public" {
  name         = "test-vm"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  hostname     = "test-vm.local"
  tags         = ["http"]
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231213"
      //image = "debian-12-bookworm-v20240515"
    }
  }

  scheduling {
    preemptible                 = true
    automatic_restart           = false
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  network_interface {
    network       = google_compute_network.vpc_network.name
    subnetwork    = google_compute_subnetwork.subnet01.name
    access_config {
        nat_ip = google_compute_address.vm1-static-ip.address
    }
  }
} 

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh-http-https"
  allow {
    protocol = "all"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}


  resource "google_compute_address" "vm1-static-ip" {
  name = "ipv4-address"
}


/*resource "google_compute_route" "default" {
  name        = "azure-route"
  dest_range  = "10.2.0.0/24"
  network     = google_compute_network.vpc_network.name
  next_hop_ip = "10.10.0.2"
  priority    = 100
}
*/