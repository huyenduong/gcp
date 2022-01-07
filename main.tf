terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.5.0"
    }
  }
}

provider "google" {
  credentials = file("terraform-gcp2.json")

  project = "gcp-huyeduongcp2-nprd-39453"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_network" "vpc_tf1" {
  name = "tf-network1"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public-subnetwork" {
  name          = "tf-subnetwork1"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_tf1.name
  }

resource "google_compute_instance" "vm_instance" {
  name         = "tf-instance1"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  tags = ["vminstance"]
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public-subnetwork.name
    access_config {
    }
  }
}

resource "google_compute_firewall" "tf-fw1" {
  name    = "test-firewall"
  network = google_compute_network.vpc_tf1.name
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22"]
  }

  target_tags = ["vminstance"]
}