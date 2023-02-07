resource "google_artifact_registry_repository" "registry" {
  provider = google-beta

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
}