provider "google" {
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = var.terraform_sa
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = var.terraform_sa
}

module "api" {
  # TODO remove after dev

  source = "git@github.com:devoteamgcloud/ml-on-gcp-pipeline.git//iac/applications/modules/api?ref=feature/automl-pipeline"
  
  project_id   = var.project_id
  api_services = var.api_services
}

resource "time_sleep" "api_propagation" {
  depends_on = [module.api]

  create_duration = "60s"
}

module "buckets" {
  for_each = var.buckets

  source = "git@github.com:devoteamgcloud/ml-on-gcp-pipeline.git//iac/applications/modules/gcs?ref=feature/automl-pipeline"

  project_id                  = var.project_id
  bucket                        = each.value.name
  bucket_location             = each.value.region
  bucket_storage_class        = "STANDARD"
  bucket_force_destroy        = false
  bucket_uniform_level_access = true

  depends_on = [time_sleep.api_propagation]
}

resource "null_resource" "dummy_pipeline_job" {
  provisioner "local-exec" {
    command = "bash run_pipeline.sh"
    environment = {
      PROJECT = var.project_id
      REGION  = var.region
      TF_SA   = var.service_accounts["terraform"].email
    }
  }
  depends_on = [time_sleep.api_propagation]
}

module "iam" {
  for_each = var.pipelines_iam
  source = "git@github.com:devoteamgcloud/ml-on-gcp-pipeline.git//iac/applications/modules/iam?ref=feature/automl-pipeline"

  project_id                     = var.project_id
  pipeline_service_account_name  = each.value.pipeline_service_account_name
  pipeline_service_account_users = each.value.pipeline_service_account_users
  pipeline_service_account_roles = each.value.pipeline_service_account_roles

  depends_on = [module.api]
}
