terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 19.3.0"
    }
  }
  required_version = ">= 1.3.0"
}
