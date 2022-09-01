resource "google_compute_network" "vpc" {
  name = "${var.workspace_name}-network"
}