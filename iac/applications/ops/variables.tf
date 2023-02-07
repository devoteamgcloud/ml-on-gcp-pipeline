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

variable "env_projects" {
  description = "The environment projects where Vertex AI will run."
  type        = set(string)
}

# Services
variable "api_services" {
  description = "GCP API services to enable"
  type        = map(string)
}

# Artifact Registry
variable "artifact_registry_repositories" {
  description = "The artifact registry repositories to create"
  type = map(object({
    location       = string
    description    = optional(string)
    format         = string
    role_group_map = map(set(string))
  }))
}

# Cloud Build
variable "repo_name" {
  type        = string
  description = "The ID of the repository containing pipelines definitions in Google Source Repositories."
}

variable "pipeline_triggers" {
  description = "The Cloud Build triggers to build pipelines."
  type = map(object({
    included      = list(string)
    path          = string
    substitutions = map(string)
    branch_regex  = string
  }))
}

variable "component_triggers" {
  description = "The Cloud Build triggers to build pipelines."
  type = map(object({
    included      = list(string)
    path          = string
    substitutions = map(string)
    branch_regex  = string
  }))
}

variable "cloudbuild_service_account_roles" {
  description = "Roles for Cloud Build SA"
  type        = list(string)
}
