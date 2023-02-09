variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "trigger_name" {
  type        = string
  description = "Name of the trigger"
}

variable "substitutions" {
  type        = map(string)
  description = "Substitutions to perform in Cloud Build"
}

variable "path" {
  type        = string
  description = "Path to the Cloud Build file"
}

variable "included" {
  type        = list(string)
  description = "File paths that trigger the trigger"
}

variable "branch_regex" {
  type        = string
  description = "Regex of the branch to run the trigger"
  default     = ".*"
}

variable "repo_name" {
  type        = string
  description = "Name of the repository"
}