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

  project_id   = var.project_id
  api_services = var.api_services
}

resource "time_sleep" "api_propagation" {
  depends_on = [module.api]

  create_duration = "60s"
}

resource "google_project_iam_custom_role" "artifact_registry_role" {
  role_id     = "artifactRegistryUser"
  title       = "Artifact Registry User"
  description = "Role to be granted to dev, uat and prod projects that need access to ops AR repositories."
  permissions = [
    "artifactregistry.packages.get",
    "artifactregistry.packages.list",
    "artifactregistry.projectsettings.get",
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.repositories.listEffectiveTags",
    "artifactregistry.repositories.listTagBindings",
    "artifactregistry.repositories.uploadArtifacts",
    "artifactregistry.tags.get",
    "artifactregistry.tags.list",
    "artifactregistry.versions.get",
    "artifactregistry.versions.list"
  ]
}

module "artifact_repository" {
  for_each = local.updated_artifact_registry_maps

  source = "git@github.com:devoteamgcloud/tf-gcp-modules-artifact-registry.git?ref=v0.0.2"

  project_id = var.project_id

  artifact_registry_repository_id  = each.key
  artifact_registry_format         = each.value.format
  artifact_registry_location       = each.value.location
  artifact_registry_description    = each.value.description
  artifact_registry_role_group_map = each.value.role_group_map

  depends_on = [time_sleep.api_propagation]
}

module "cloud_build" {
  for_each = merge(var.pipeline_triggers, var.component_triggers)
  # tflint-ignore: terraform_module_pinned_source
  source = "git@github.com:devoteamgcloud/accel-vertex-ai-cookiecutter-templates.git//terraform-modules/cloud_build"

  included      = each.value.included
  path          = each.value.path
  branch_regex  = each.value.branch_regex
  project_id    = var.project_id
  repo_name     = var.repo_name
  substitutions = local.cloud_build_substitutions[each.key]
  trigger_name  = each.key

  depends_on = [time_sleep.api_propagation]
}

module "basic" {
  source = "git@github.com:devoteamgcloud/terraform-gcp-foundation.git//iam/basic?ref=v0.2.7"

  groups           = local.groups
  projects         = local.project_iam
  service_accounts = local.all_service_accounts
  folders          = local.folders
}
