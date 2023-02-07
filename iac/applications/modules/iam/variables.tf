variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "pipeline_service_account_name" {
  type        = string
  description = "Name of the service account for the pipeline."
}

variable "pipeline_service_account_users" {
  type        = list(any)
  description = "Users of the service account for the pipeline."
}

variable "pipeline_service_account_roles" {
  type        = list(string)
  description = "IAM roles of the service account for the pipeline."
}

variable "cloudbuild_service_account_roles" {
  type        = list(string)
  description = "IAM roles of the service account for Cloud Build."
}