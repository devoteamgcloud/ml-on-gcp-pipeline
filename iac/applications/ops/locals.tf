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
      "_PROJECT_ROOT"                     = "ml-on-gcp"
      "_REGION"                           = var.region
      "_ARTIFACT_REGISTRY_CONTAINERS_URL" = "${var.artifact_registry_repositories["pipeline-containers"].location}-docker.pkg.dev/${var.project_id}/pipeline-containers"
      "_ARTIFACT_REGISTRY_TEMPLATES_URL"  = "https://${var.artifact_registry_repositories["pipeline-containers"].location}-kfp.pkg.dev/${var.project_id}/pipeline-templates"
    }) }
  )
  # IAM
  groups  = defaults(var.groups, {})
  folders = defaults(var.folders, {})

  group_roles = defaults(var.group_roles, {})
  user_roles  = defaults(var.user_roles, {})

  cloud_build_service_account = {
    email  = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
    create = false
  }

  service_accounts = merge(
    var.service_accounts,
    { "cloudbuild" : local.cloud_build_service_account },
    {
      for project in data.google_project.env_projects : project.project_id => {
        email  = "service-${project.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
        create = false
      }
    }
  )

  service_account_roles = defaults(var.service_account_roles, {})

  service_agents = {
    "artifactregistry.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
      create = false
    },
    "cloudbuild.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
      create = false
    },
    "containerregistry.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@containerregistry.iam.gserviceaccount.com"
      create = false
    },
    "pubsub.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
      create = false
    },
  }

  all_service_accounts = merge(local.service_agents, local.service_accounts)

  default_roles = {
    "artifactregistry.googleapis.com" : ["roles/artifactregistry.serviceAgent"],
    "cloudbuild.googleapis.com" : ["roles/cloudbuild.serviceAgent"],
    "containerregistry.googleapis.com" : ["roles/containerregistry.ServiceAgent"],
    "pubsub.googleapis.com" : ["roles/pubsub.serviceAgent"],
  }

  ar_reader_roles = {
    for project in data.google_project.env_projects : project.project_id => ["projects/${var.project_id}/roles/artifactRegistryUser"]
  }

  project_iam = {
    "ml-on-gcp" = {
      "project_id" = var.project_id
      "groups"     = local.group_roles
      "sa"         = merge(local.service_account_roles, local.default_roles, local.ar_reader_roles)
      "users"      = local.user_roles
    }
  }
}