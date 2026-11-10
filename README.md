# Boutique Platform - GKE + Istio + Observability Lab

This repository contains a cloud-native platform engineering and observability laboratory built on Google Cloud's Online Boutique microservices demo. It provides automated infrastructure provisioning on Google Kubernetes Engine (GKE Standard zonal cluster) via Terraform, application service mesh integration with Istio, and telemetry metrics collection via Prometheus and Prometheus Operator monitors.

Based on GoogleCloudPlatform/microservices-demo (Apache-2.0)

---

## Architecture

```
[ Internet / Clients ]
          |
          v
   [ Istio Ingress Gateway ]
          |
   +------+-------------------------------+
   |      |        GKE Standard Cluster   |
   |      v                               |
   | [ frontend ]                         |
   |   |--> [ cartservice ] -> [ redis ]  |
   |   |--> [ productcatalogservice ]     |
   |   |--> [ currencyservice ]           |
   |   |--> [ paymentservice ]            |
   |   |--> [ shippingservice ]           |
   |   |--> [ emailservice ]              |
   |   |--> [ checkoutservice ]           |
   |   |--> [ recommendationservice ]     |
   |   |--> [ adservice ]                 |
   +--------------------------------------+
          |
    [ Prometheus Operator ]
    (istiod ServiceMonitor & envoy-stats PodMonitor)
```

*(Detailed architecture diagram and traffic topology placeholder)*

---

## Cost Warnings

> [!WARNING]
> This laboratory creates billable Google Cloud resources. Provisioned resources include:
> - **GKE Cluster Management Fee**: Standard zonal cluster management fee (`[$X.XX/cluster/month]`).
> - **Compute Engine Worker Nodes**: 3 x `e2-standard-4` Spot VM instances (`[$X.XX/day]`). Spot instances reduce compute costs by ~60–90% compared to on-demand pricing, but instances may be preempted.
> - **External Load Balancing**: Cloud Load Balancer / Gateway API IP allocations (`[$X.XX/day]`).
> - **Cloud Memorystore (Redis)**: Optional; if enabled via `memorystore = true`, provisions a 1GB Basic tier Redis instance (`[$X.XX/month]`).
> - **Cloud Storage**: GCS bucket for remote Terraform state storage (`[$X.XX/month]`).
>
> Always execute the [Teardown](#teardown) instructions when not in use to avoid unexpected billing charges.

---

## Prerequisites

- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- A Google Cloud Project with Billing enabled

---

## Run Steps

### 1. Authenticate to Google Cloud
Configure your Google Cloud CLI session and project:

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project <your-project-id>
```

### 2. Configure Terraform Variables
Copy the example variables file and adjust parameters as needed:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual GCP Project ID:
# gcp_project_id = "<your-project-id>"
```

### 3. Initialize Terraform with Remote GCS Backend
Ensure your GCS state bucket exists, then initialize Terraform:

```bash
# Optional: create state bucket if not already created
# gcloud storage buckets create gs://<your-tf-state-bucket> --location=europe-west1

terraform init -backend-config="bucket=<your-tf-state-bucket>"
```

### 4. Plan and Apply Infrastructure
Review planned resources and provision the cluster:

```bash
terraform plan
terraform apply
```

*Provisioning typically takes `[~X minutes]`.*

### 5. Connect to the Cluster
Retrieve GKE cluster credentials:

```bash
gcloud container clusters get-credentials boutique-platform --zone=europe-west1-b --project=<your-project-id>
```

### 6. Deploy Workloads and Observability
Deploy the Online Boutique services via Kustomize and apply the Istio Prometheus monitors:

```bash
# Apply workloads
kubectl apply -k ../kustomize/

# Apply Istio Prometheus monitors
kubectl apply -f ../observability/istio-monitors.yaml
```

---

## Teardown

To tear down all resources and stop incurring costs:

```bash
# 1. Delete application workloads
kubectl delete -k ../kustomize/

# 2. Destroy infrastructure via Terraform
cd terraform
terraform destroy
```

*Teardown typically takes `[~X minutes]`.*

---

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](file:///home/themoosalah/Devops%20projects/new/microservices-demo/LICENSE) file for details.
Based on GoogleCloudPlatform/microservices-demo (Apache-2.0).
