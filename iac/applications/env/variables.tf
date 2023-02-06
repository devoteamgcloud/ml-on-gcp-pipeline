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
