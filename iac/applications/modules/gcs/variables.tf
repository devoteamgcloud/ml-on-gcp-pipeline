variable "bucket" {
  type        = string
  description = "Bucket name"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "bucket_location" {
  description = "GCP region"
  type        = string
}

variable "bucket_storage_class" {
  description = "Storage class"
  type        = string
}

variable "bucket_force_destroy" {
  description = "Enable force destroy"
  type        = bool
}

variable "bucket_uniform_level_access" {
  description = "Enable uniform level access"
  type        = bool
}