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
  ip_cidr_range = "10.2.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "vm_instance_public" {
  name         = "test-vm"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  hostname     = "test-vm.local"
  tags         = ["ssh","http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231213"
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
        nat_ip = google_compute_address.static.address
    }
  }
} 

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}


  resource "google_compute_address" "static" {
  name = "ipv4-address"
}

