mock_provider "gitlab" {
  mock_data "gitlab_group" {
    defaults = {
      id = "12345"
    }
  }

  mock_data "gitlab_user" {
    defaults = {
      id = "67890"
    }
  }

  mock_data "gitlab_metadata" {
    defaults = {
      enterprise = true
    }
  }
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "default_branch_not_in_branch_protection" {
  variables {
    name           = "basic-${run.setup.random_string}"
    namespace      = "basic-${run.setup.random_string}"
    default_branch = "develop"

    branch_protection = {
      main = {
        users_allowed_to_push = ["user"]
      }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = toset(keys(resource.gitlab_branch_protection.default)) == toset(["develop", "main"])
    error_message = "Expected branch protection for the default branch and main"
  }

  assert {
    condition     = jsonencode(local.branch_protection_allowed_to["develop"].merge) == jsonencode([{ access_level = "developer" }])
    error_message = "Invalid allowed_to_merge on default branch"
  }

  assert {
    condition     = jsonencode(local.branch_protection_allowed_to["develop"].push) == jsonencode([{ access_level = "no one" }])
    error_message = "Invalid allowed_to_push on default branch"
  }

  assert {
    condition     = resource.gitlab_branch_protection.default["develop"].allow_force_push == false
    error_message = "Allow Force push should be disabled on default branch"
  }

  assert {
    condition     = resource.gitlab_branch_protection.default["develop"].code_owner_approval_required == false
    error_message = "Code owner approval should not be required on default branch"
  }

  assert {
    condition     = jsonencode(local.branch_protection_allowed_to["main"].push) == jsonencode([{ access_level = "no one" }, { user_id = "67890" }])
    error_message = "Expected the no one access level and one user allowed to push on main"
  }
}

run "enterprise_unprotect_access_level" {
  variables {
    name      = "basic-${run.setup.random_string}"
    namespace = "basic-${run.setup.random_string}"

    branch_protection = {
      main = {
        unprotect_access_level      = "maintainer"
        groups_allowed_to_unprotect = ["foo/group1"]
      }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = jsonencode(local.branch_protection_allowed_to["main"].unprotect) == jsonencode([{ access_level = "maintainer" }, { group_id = "12345" }])
    error_message = "Expected unprotect_access_level to be passed as an access_level entry of allowed_to_unprotect"
  }

  assert {
    condition     = resource.gitlab_branch_protection.default["main"].allowed_to_unprotect != null
    error_message = "allowed_to_unprotect should be set on main"
  }
}

run "community_edition" {
  variables {
    name      = "basic-${run.setup.random_string}"
    namespace = "basic-${run.setup.random_string}"

    branch_protection = {
      main = {
        merge_access_level = "maintainer"
        push_access_level  = "developer"
      }
    }
  }

  module {
    source = "./"
  }

  override_data {
    target = data.gitlab_metadata.default
    values = {
      enterprise = false
    }
  }

  command = plan

  assert {
    condition     = resource.gitlab_branch_protection.default["main"].merge_access_level == "maintainer"
    error_message = "Invalid merge_access_level on CE"
  }

  assert {
    condition     = resource.gitlab_branch_protection.default["main"].push_access_level == "developer"
    error_message = "Invalid push_access_level on CE"
  }

  assert {
    condition = alltrue([
      length(local.branch_protection_allowed_to["main"].merge) == 0,
      length(local.branch_protection_allowed_to["main"].push) == 0,
      length(local.branch_protection_allowed_to["main"].unprotect) == 0,
    ])
    error_message = "allowed_to_* should not be set on CE"
  }
}

run "mirror_overwrites_diverged_branches" {
  variables {
    name           = "basic-${run.setup.random_string}"
    namespace      = "basic-${run.setup.random_string}"
    default_branch = "develop"
    import_url     = "https://example.com/repo.git"
    mirror         = true

    branch_protection = {
      main = {
        users_allowed_to_push = ["user"]
      }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = length(resource.gitlab_branch_protection.default) == 0
    error_message = "Expected no branch protection when mirroring and overwriting diverged branches"
  }
}

run "mirror_does_not_overwrite_diverged_branches" {
  variables {
    name                                = "basic-${run.setup.random_string}"
    namespace                           = "basic-${run.setup.random_string}"
    default_branch                      = "develop"
    import_url                          = "https://example.com/repo.git"
    mirror                              = true
    mirror_overwrites_diverged_branches = false

    branch_protection = {
      main = {
        users_allowed_to_push = ["user"]
      }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = toset(keys(resource.gitlab_branch_protection.default)) == toset(["develop", "main"])
    error_message = "Expected branch protection for the default branch and main"
  }
}
