variable "api_services" {
  description = "GCP API services to enable"
  type        = map(string)
}

variable "project_id" {
  description = "Project ID"
  type        = string
}