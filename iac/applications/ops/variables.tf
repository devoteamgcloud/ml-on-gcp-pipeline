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

# IAM
variable "groups" { type = any }

variable "folders" { type = any }

variable "service_accounts" {
  type = map(object({
    gcp_project_id = optional(string)
    description    = optional(string)
    display_name   = optional(string)
    create         = optional(bool)
    disabled       = optional(bool)
    email          = optional(string)
    groups         = optional(map(list(string)))
    sa             = optional(map(list(string)))
    users          = optional(map(list(string)))
    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    name           = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
  }))
}

variable "group_roles" { type = any }

variable "service_account_roles" { type = any }

variable "user_roles" { type = any }
