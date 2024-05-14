terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  project = "arma-422614"
  region = "us-central1"
  zone = "us-central1-a"
  credentials = "arma-422614-1f0053d9ea86.json"
}

resource google_compute_network "arma_vpc" {
  name = "arma-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_address" "my_static_ip" {
  name   = "my-static-ip"
  region = "us-central1"  # Replace with your desired region
}

resource google_compute_subnetwork "arma_subnetwork" {
  name = "arma-subnetwork"
  network = google_compute_network.arma_vpc.name
  ip_cidr_range = "10.10.100.0/24"
  region = "us-central1"
  private_ip_google_access = false
}

resource "google_compute_instance" "arma-vm" {
    name = "arma-vm"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    allow_stopping_for_update = true
    depends_on = [ google_compute_firewall.allow-icmp ]
  
  network_interface {
    network = google_compute_network.arma_vpc.id
    subnetwork = google_compute_subnetwork.arma_subnetwork.id

    access_config {
      // Specify the static IP address here
      nat_ip = google_compute_address.my_static_ip.address
    }
  }

  

  boot_disk {
    auto_delete = true
    device_name = "instance-20240509-001319"

    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }
}

resource "google_compute_firewall" "allow-icmp" {
  name = "allow-icmp"
  network = google_compute_network.arma_vpc.id
  source_ranges = ["0.0.0.0/0"]
  priority = 1000

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22", "80", "443"]
  }

}

output "auto" {
    value = google_compute_network.arma_vpc.id
}
