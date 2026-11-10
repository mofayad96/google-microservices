# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Definition of local variables
locals {
  base_apis = [
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudprofiler.googleapis.com"
  ]
}

# Enable Google Cloud APIs
module "enable_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.gcp_project_id
  disable_services_on_destroy = false

  activate_apis = local.base_apis
}

# Create Standard zonal GKE cluster
resource "google_container_cluster" "my_cluster" {
  name     = var.name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  ip_allocation_policy {
  }

  depends_on = [
    module.enable_google_apis
  ]
}

# Create Node Pool (3 x e2-standard-4, spot, GKE_METADATA)
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.my_cluster.name
  node_count = 3

  node_config {
    machine_type = "e2-standard-4"
    spot         = true

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
