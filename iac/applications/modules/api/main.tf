resource "google_project_service" "api" {
  for_each                   = var.api_services
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}