resource "google_compute_instance" "vm_2" {
  name         = "test-vm2"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  hostname     = "test-vm2.local"
  tags         = ["http"]

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
        nat_ip = google_compute_address.vm2-static-ip.address
    }
  }
} 


  resource "google_compute_address" "vm2-static-ip" {
  name = "ipv4-address-vm2"
}