variable "project_id" {
  type        = string
  description = "Project ID of the project"
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "terraform_sa" {
  description = "Service account to impersonate for Terraform"
  type        = string
}

# Services
variable "api_services" {
  description = "GCP API services to enable"
  type        = map(string)
}

# GCS
variable "buckets" {
  type = map(object({
    name   = string
    region = string
  }))
  description = "Defines the buckets to be built."
}

# IAM
variable "pipelines_iam" { 
  type = map(object({
    pipeline_service_account_name  = string
    pipeline_service_account_users = map(string)
    pipeline_service_account_roles = map(string)
  })) 
  description = "Pipeline service account users and roles"
}
