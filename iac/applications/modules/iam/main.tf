# Vertex AI SA
resource "google_service_account" "sa-vertex-pipeline" {
  project    = var.project_id
  account_id = var.pipeline_service_account_name
  depends_on = [google_project_service.billing_api]
}

resource "google_project_iam_member" "sa-vertex-pipeline" {
  for_each = toset(var.pipeline_service_account_roles)
  project    = var.project_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.sa-vertex-pipeline.email}"
  depends_on = [google_service_account.sa-vertex-pipeline]
}

resource "google_service_account_iam_member" "sa-vertex-pipeline-users" {
  for_each           = toset(var.pipeline_service_account_users)
  service_account_id = google_service_account.sa-vertex-pipeline.id
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${each.value}"
}
