variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "repository_id" {
  type        = string
  description = "Name of the artifact registry repository"
}

variable "location" {
  type        = string
  description = "Location of the artifact registry repository"
}

variable "description" {
  type        = string
  description = "Description of the artifact repository"
}

variable "format" {
  type        = string
  description = "Format of the artifacts in this repository"
}