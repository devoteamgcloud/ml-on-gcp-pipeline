provider "google" {
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = var.service_accounts["terraform"].email
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = var.service_accounts["terraform"].email
}

module "api" {
  # TODO remove after dev
  # tflint-ignore: terraform_module_pinned_source
  source = "git@github.com:devoteamgcloud/accel-vertex-ai-cookiecutter-templates.git//terraform-modules/api"
  # source       = "git@github.com:devoteamgcloud/accel-vertex-ai-cookiecutter-templates.git//terraform-modules/api?ref=feature/base-template"
  project_id   = var.project_id
  api_services = var.api_services
}

resource "time_sleep" "api_propagation" {
  depends_on = [module.api]

  create_duration = "60s"
}

module "buckets" {
  for_each = var.buckets

  source = "git@github.com:devoteamgcloud/tf-gcp-modules-cloud-storage.git?ref=v0.0.2"

  project_id                  = var.project_id
  name                        = each.value.name
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

module "basic" {
  source = "git@github.com:devoteamgcloud/terraform-gcp-foundation.git//iam/basic?ref=v0.2.7"

  groups           = local.groups
  projects         = local.project_iam
  service_accounts = local.all_service_accounts
  folders          = local.folders

  depends_on = [null_resource.dummy_pipeline_job]
}
