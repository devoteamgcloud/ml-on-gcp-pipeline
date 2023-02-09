data "google_project" "env_projects" {
  for_each = var.env_projects

  project_id = each.value
}

data "google_project" "project" {}

locals {
  vertex_ai_service_agents = [for project in data.google_project.env_projects : "serviceAccount:service-${project.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"]
  updated_artifact_registry_maps = {
    for artifact_repo_name, artifact_repo_content in var.artifact_registry_repositories : artifact_repo_name => {
      location    = artifact_repo_content.location
      description = artifact_repo_content.description
      format      = artifact_repo_content.format
      role_group_map = lookup(artifact_repo_content.role_group_map, "roles/artifactregistry.reader", null) != null ? tomap({
        for role, groups in artifact_repo_content.role_group_map : role => role == "roles/artifactregistry.reader" ? tolist(set(concat(groups, local.vertex_ai_service_agents))) : groups
        }) : tomap({
        "roles/artifactregistry.reader" = tolist(local.vertex_ai_service_agents)
      })
    }
  }
  cloud_build_substitutions = merge(
    { for trigger_name, config in merge(var.pipeline_triggers, var.component_triggers) : trigger_name => merge(config.substitutions, {
      "_PROJECT_ROOT"                     = "ml-on-gcp-pipeline"
      "_REGION"                           = var.region
      "_ARTIFACT_REGISTRY_CONTAINERS_URL" = "${var.artifact_registry_repositories["pipeline-containers"].location}-docker.pkg.dev/${var.project_id}/pipeline-containers"
      "_ARTIFACT_REGISTRY_TEMPLATES_URL"  = "https://${var.artifact_registry_repositories["pipeline-containers"].location}-kfp.pkg.dev/${var.project_id}/pipeline-templates"
    }) }
  )

}