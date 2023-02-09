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

  source = "git@github.com:devoteamgcloud/ml-on-gcp-pipeline.git//iac/applications/modules/api"
  
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

module "artifact_registry" {
  for_each = var.artifact_registry_repositories

  source = "git@github.com:devoteamgcloud/ml-on-gcp-pipeline.git//iac/applications/modules/artifact-registry"

  description   = each.value.description
  format        = each.value.format
  location      = each.value.location
  project_id    = var.project_id
  repository_id = each.key

  depends_on = [module.api]
}

module "cloud_build" {
  for_each = merge(var.pipeline_triggers, var.component_triggers)
  # tflint-ignore: terraform_module_pinned_source
  source = "git@github.com:devoteamgcloud/ml-on-gcp-pipeline.git//iac/applications/modules/cloud-build"

  included      = each.value.included
  path          = each.value.path
  branch_regex  = each.value.branch_regex
  project_id    = var.project_id
  repo_name     = var.repo_name
  substitutions = local.cloud_build_substitutions[each.key]
  trigger_name  = each.key

  depends_on = [time_sleep.api_propagation]
}

# Cloud Build - grant additional permissions
resource "google_project_iam_member" "cloud-build" {
  for_each = toset(var.cloudbuild_service_account_roles)
  project    = var.project_id
  role       = each.value
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [time_sleep.api_propagation]
}
