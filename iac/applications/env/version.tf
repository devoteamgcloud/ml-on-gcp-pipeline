terraform {
  required_version = "~>1.1.7"
  required_providers {
    google = {
      version = "~>4.12.0"
    }
    google-beta = {
      version = "~>4.12.0"
    }
    time = {
      version = "~>0.9.1"
    }
  }
  backend "gcs" {}
  experiments = [module_variable_optional_attrs]
}
