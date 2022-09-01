resource "google_compute_address" "static_ip" {
  name = "${var.workspace_name}-debian"
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "${var.workspace_name}-allow-ssh"
  network       = google_compute_network.vpc.name
  target_tags   = ["allow-ssh"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

data "google_client_openid_userinfo" "me" {}

resource "google_compute_instance" "debian" {
  name         = "debian"
  machine_type = "e2-micro"
  tags         = ["allow-ssh"]

  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}

output "public_ip" {
  value = google_compute_address.static_ip.address
}