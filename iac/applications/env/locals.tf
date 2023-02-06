data "google_project" "project" {}

locals {

  # IAM
  groups  = defaults(var.groups, {})
  folders = defaults(var.folders, {})

  group_roles = defaults(var.group_roles, {})
  user_roles  = defaults(var.user_roles, {})

  cloud_build_service_account = {
    email  = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
    create = false
  }

  service_accounts = merge(var.service_accounts, { "cloudbuild" : local.cloud_build_service_account })

  service_account_roles = defaults(var.service_account_roles, {})

  service_agents = {
    "aiplatform.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
      create = false
    },
    "cc-aiplatform.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@gcp-sa-aiplatform-cc.iam.gserviceaccount.com"
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
    "ml.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@cloud-ml.google.com.iam.gserviceaccount.com"
      create = false
    },
    "pubsub.googleapis.com" = {
      email  = "service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
      create = false
    },
  }

  all_service_accounts = merge(local.service_agents, local.service_accounts)

  default_roles = {
    "aiplatform.googleapis.com" : ["roles/aiplatform.serviceAgent"],
    "cc-aiplatform.googleapis.com" : ["roles/aiplatform.customCodeServiceAgent"],
    "cloudbuild.googleapis.com" : ["roles/cloudbuild.serviceAgent"],
    "containerregistry.googleapis.com" : ["roles/containerregistry.ServiceAgent"],
    "ml.googleapis.com" : ["roles/ml.serviceAgent"],
    "pubsub.googleapis.com" : ["roles/pubsub.serviceAgent"],
  }

  project_iam = {
    "ml-on-gcp" = {
      "project_id" = var.project_id
      "groups"     = local.group_roles
      "sa"         = merge(local.service_account_roles, local.default_roles)
      "users"      = local.user_roles
    }
  }
}