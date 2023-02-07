resource "google_cloudbuild_trigger" "default" {
  project        = var.project_id
  name           = var.trigger_name
  substitutions  = var.substitutions
  filename       = var.path
  included_files = var.included

  github {
    owner = "devoteamgcloud"
    name  = var.repo_name
    push {
      branch = var.branch_regex
    }
  }
}