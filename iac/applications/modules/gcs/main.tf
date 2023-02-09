resource "google_storage_bucket" "bucket" {
  name                        = var.bucket
  project                     = var.project_id 
  location                    = var.bucket_location
  storage_class               = var.bucket_storage_class
  force_destroy               = var.bucket_force_destroy
  uniform_bucket_level_access = var.bucket_uniform_level_access
}