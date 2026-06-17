# AWS EKS & Flask Application Deployment Infrastructure

A production-ready, highly available, and highly secure AWS infrastructure engineered using **Terraform**, deploying a containerized **Flask Application** into an **Amazon EKS (Elastic Kubernetes Service)** cluster via **Helm Charts**, fully automated through **GitHub Actions CI/CD**.

---

## 🏗️ Architectural & Design Decisions

This infrastructure was built from scratch with a rigorous focus on the core DevOps pillars: **Security, Performance, and Cost Optimization**.

### 1. Networking & High Availability (VPC)
* **Multi-AZ Architecture:** Built a custom Virtual Private Cloud (VPC) spanning multiple Availability Zones (AZs) using pairs of Public and Private Subnets to guarantee strict high availability (HA).
* **Isolation of Concerns:** The EKS Worker Nodes reside exclusively inside private subnets, shielded from the public internet, ensuring that your core workloads are safe from external network attacks.
* **Controlled Ingress/Egress:** Public subnets house the Internet Gateway (IGW) and NAT Gateways, allowing instances in private subnets to pull updates securely without exposing their internal ports.

### 2. Containerization & Security (Docker & ECR)
* **Multi-Stage Builds:** The `Dockerfile` separates the build dependencies (using `build-essential`) from the minimal final runtime layer. This minimizes the final image size, leading to **faster deployment times and lowered storage costs**.
* **Attack Surface Reduction:** Utilized `python:3.11-slim` as the base execution tier to keep vulnerabilities to an absolute minimum.
* **Non-Root Execution:** Adhered strictly to security best practices by preventing the container from running as `root`. Created a low-privilege system user (`appuser` with UID 10001) to run the Flask daemon.

### 3. Orchestration & Resiliency (EKS & Helm)
* **Resource Constraints:** Implemented hard memory and CPU `requests` and `limits` within the Helm configurations to protect nodes against potential resource exhaustion or memory leaks.
* **Proactive Self-Healing:** Configured standard `livenessProbe` and `readinessProbe` targeting the Flask `/health` endpoint, empowering Kubernetes to automatically recycle unhealthy pods and route traffic only to operational containers.
* **Secure Pod Enforcement:** Injected `securityContext` directly into the deployment manifests to strictly enforce `runAsNonRoot: true` at the orchestration boundary.

### 4. Cost Efficiency
* **Right-Sized Sizing:** Provisioned the node groups with lean EC2 instance types, keeping operational AWS costs minimal for evaluating and debugging stages while allowing immediate horizontal scalability when traffic rises.

### 5. Automated CI/CD (GitHub Actions)
* **Secretless Auth (OIDC):** Configured standard IAM OpenID Connect (OIDC) identity providers. The pipeline dynamically assumes roles from AWS using temporary tokens instead of storing permanent, highly risky `AWS_ACCESS_KEY_ID` combinations inside GitHub Secrets.
* **Immutable Deployments:** Every build tags the Docker image using the unique `github.sha` fingerprint, entirely bypassing the dangerous tracking issues of the `latest` tag and ensuring clean rollback capabilities.

---

## 🚀 How to Deploy & Manage

### Prerequisites
* Terraform >= 1.5.0
* AWS CLI configured with admin privileges
* kubectl & Helm v3

### 1. Provisioning the Cloud Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply --auto-approve
---

## 🔗 Public Access Endpoints

* **Application URL:** http://a9c7ac627c8d74c9c9df02f7bbd1fa39-1036883592.us-east-1.elb.amazonaws.com
* **Health Check URL:** http://a9c7ac627c8d74c9c9df02f7bbd1fa39-1036883592.us-east-1.elb.amazonaws.com/health