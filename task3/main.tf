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
  region = "europe-west2"
  zone = "europe-west2-a"
  credentials = "arma-422614-1f0053d9ea86.json"
}

resource google_compute_network "eu1_arma_vpc" {
  name = "eu1-arma-vpc"
  auto_create_subnetworks = false
}

resource google_compute_network "us1_arma_vpc" {
  name = "us1-arma-vpc"
  auto_create_subnetworks = false
}

resource google_compute_network "us2_arma_vpc" {
  name = "us2-arma-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_address" "eu1_static_ip" {
  name   = "eu1-static-ip"
  region = "europe-west2"  # Replace with your desired region
}

resource "google_compute_address" "us1_static_ip" {
  name   = "us1-static-ip"
  region = "us-east1"  # Replace with your desired region
}

resource "google_compute_address" "us2_static_ip" {
  name   = "us2-static-ip"
  region = "us-east1"  # Replace with your desired region
}

resource google_compute_subnetwork "ue1_arma_subnetwork" {
  name = "arma-subnetwork"
  network = google_compute_network.eu1_arma_vpc.name
  ip_cidr_range = "10.10.100.0/24"
  region = "europe-west2"
  private_ip_google_access = false
}

resource google_compute_subnetwork "us1_subnetwork" {
    name = "us1-subnet"
    network = google_compute_network.us1_arma_vpc.id
    ip_cidr_range = "192.168.100.0/24"
    region = "us-east1"
    private_ip_google_access = false
}

resource google_compute_subnetwork "us2_subnetwork" {
    name = "us2-subnet"
    network = google_compute_network.us2_arma_vpc.id
    ip_cidr_range = "192.168.200.0/24"
    region = "us-east1"
    private_ip_google_access = false
}

resource "google_compute_instance" "eu1-arma-vm" {
    name = "arma-vm"
    machine_type = "e2-micro"
    zone = "europe-west2-a"
    allow_stopping_for_update = true
    depends_on = [ google_compute_firewall.allow-icmp ]
  
  network_interface {
    network = google_compute_network.eu1_arma_vpc.id
    subnetwork = google_compute_subnetwork.ue1_arma_subnetwork.id

    access_config {
      // Specify the static IP address here
      nat_ip = google_compute_address.eu1_static_ip.address
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

resource "google_compute_instance" "us1-arma-vm" {
    name = "us1-arma-vm"
    machine_type = "e2-micro"
    zone = "us-east1-b"
    allow_stopping_for_update = true
    depends_on = [ google_compute_firewall.allow-icmp ]
  
  network_interface {
    network = google_compute_network.us1_arma_vpc.id
    subnetwork = google_compute_subnetwork.us1_subnetwork.id

    access_config {
      // Specify the static IP address here
      nat_ip = google_compute_address.us1_static_ip.address
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

resource "google_compute_instance" "us2-arma-vm" {
    name = "arma-vm"
    machine_type = "e2-micro"
    zone = "us-east1-b"
    allow_stopping_for_update = true
    depends_on = [ google_compute_firewall.allow-icmp ]
  
  network_interface {
    network = google_compute_network.us2_arma_vpc.id
    subnetwork = google_compute_subnetwork.us2_subnetwork.id

    access_config {
      // Specify the static IP address here
      nat_ip = google_compute_address.us2_static_ip.address
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

  metadata_startup_script = "echo 'Script Working!' > ./gcp-data-script.txt"
}


resource "google_compute_firewall" "allow-icmp" {
  name = "allow-icmp"
  network = google_compute_network.us1_arma_vpc.id
  source_ranges = ["0.0.0.0/0"]
  priority = 1000

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22", "80"]
  }

}

output "auto" {
    value = google_compute_network.us1_arma_vpc.id
}
