<!-- Copyright 2022 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. -->

# Terraform Infrastructure for Boutique Platform GKE Cluster

This directory contains Terraform configurations to provision the underlying GKE infrastructure for the Boutique Platform lab.

## Architecture

- **GKE Cluster**: Standard zonal cluster (`boutique-platform`) located in `europe-west1-b` with default node pool removed, Workload Identity enabled, `REGULAR` release channel, Standard Gateway API enabled, and `deletion_protection = false`.
- **Node Pool**: 3 x `e2-standard-4` spot instances with `GKE_METADATA` workload metadata configuration.
- **Backend**: Google Cloud Storage (`gcs`) with prefix `gke-platform` (bucket supplied during `terraform init`).
- **Decoupled Deployment**: Application workloads are deployed separately via Kustomize (not applied by Terraform).

## Usage

1. Copy the example variable definition:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Edit `terraform.tfvars` and specify your `gcp_project_id`.
3. Initialize Terraform with your GCS state bucket:
   ```bash
   terraform init -backend-config="bucket=<your-tf-state-bucket>"
   ```
4. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Teardown

```bash
terraform destroy
```
