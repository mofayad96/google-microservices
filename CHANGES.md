# Changelog & Platform Migration

This document tracks changes made to adapt the upstream Google Cloud Online Boutique repository into a customized GKE + Istio + Observability lab platform.

## Initial Repository Preparation (`cleanup` branch)

### 1. Version Control & Repository Hygiene
- Renamed upstream remote `origin` to `upstream`.
- Removed tracked `terraform/terraform.tfvars` from git tracking and added `.gitignore` rules for local variables, state files, crash logs, plan files, credentials, and environment files.
- Added `terraform/terraform.tfvars.example` for reference.
- Maintained tracking of `.terraform.lock.hcl`.

### 2. Infrastructure as Code (Terraform)
- **Cluster Architecture**: Replaced the Autopilot cluster with a Standard zonal GKE cluster (`boutique-platform`) located in `europe-west1-b` (`remove_default_node_pool = true`, Workload Identity enabled, release channel `REGULAR`, Gateway API `CHANNEL_STANDARD`, and `deletion_protection = false`).
- **Node Pool**: Added a 3-node spot pool using `e2-standard-4` instances with `GKE_METADATA` workload metadata configuration.
- **Remote State**: Configured Google Cloud Storage (GCS) backend with prefix `gke-platform` (bucket supplied at initialization).
- **Decoupled Application Deployment**: Removed local-exec `kubectl apply` and `kubectl wait` provisions from Terraform. Application workloads will be deployed separately via Kustomize.
- **Region/Zone Standardization**: Configured default region to `europe-west1` and default zone to `europe-west1-b`.

### 3. Upstream CI Cleanup
- Deleted upstream CI workflows (`.github/workflows/*`) targeting Google-internal infrastructure.
- Deleted upstream `.github/CODEOWNERS` and `.deploystack/` directories.
- Preserved application source code (`src/`), manifests (`kubernetes-manifests/`, `kustomize/`, `istio-manifests/`), and original Apache-2.0 `LICENSE`.

### 4. Lab Scaffolding
- Added Prometheus Operator custom resource definitions in `observability/istio-monitors.yaml`:
  - `ServiceMonitor` for `istiod` (`monitoring` namespace, selecting `istio-system`, port `http-monitoring`, 15s scrape interval).
  - `PodMonitor` for `envoy-stats` (`monitoring` namespace, selecting pods with `security.istio.io/tlsMode`, port `http-envoy-prom`, path `/stats/prometheus`, 15s scrape interval).
- Added GitHub Actions workflow `.github/workflows/terraform.yml` with Workload Identity Federation (WIF) authentication for Terraform linting, validation, and planning.

### 5. Component & Tooling Cleanup
- **Google CI & Release Tooling Removed**: Deleted `helm-chart/`, `cloudbuild.yaml`, `.github/release-cluster/`, `.github/terraform/`, `docs/releasing/`, and `docs/cloudshell-tutorial.md`.
- **Unused Kustomize Components Removed**: Deleted `kustomize/components/` variants for `alloydb/`, `spanner/`, `shopping-assistant/`, `cymbal-branding/`, and `single-shared-session/`.
- **Redundant Ingress Patch Removed**: Deleted `kustomize/components/non-public-frontend/` whose frontend patch conflicts with `service-mesh-istio`.
- **Memorystore Cleaned Up**: Removed `terraform/memorystore.tf`, `kustomize/components/memorystore/`, and corresponding test/variables in favor of in-cluster Redis.
- **Preserved Core Lab Assets**: Retained `base`, `service-mesh-istio`, `google-cloud-operations`, and `without-loadgenerator` (with `loadgenerator` active by default for traffic generation).
