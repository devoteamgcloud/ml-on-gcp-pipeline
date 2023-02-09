# Vertex AI Accelerator: Ops Terraform

## Prerequisites

- Have a service account with Owner access #TODO: refine
- Have the Service Account Token Creator role on this service account

## Manual steps before executing terraform

Create the following:
* A project on GCP
* A service account on that project (easiest is to just call it `terraform@{PROJECT_ID}.iam.gserviceaccount.com)`
  * This service account should have **Owner** role on the project # TODO: change to more granular permissions
* A bucket to hold the terraform state (easiest is to just call it `gcs-{PROJECT_ID}-tfstate`)
* Ensure you have the **Service Account Token Creator** on role on the service account


## Running Terraform

```bash
terraform init --backend-config=ops.backend
```
With {ENV} the environment (dev, uat, prod)

## Deploy your infrastructure

```bash
terraform init --backend-config=ops.backend
terraform plan --out tf.plan --var-file=ops.tfvars
terraform apply tf.plan
```
