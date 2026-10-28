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
    condition     = resource.gitlab_branch_protection.default["develop"].merge_access_level == "developer"
    error_message = "Invalid merge_access_level on default branch"
  }

  assert {
    condition     = resource.gitlab_branch_protection.default["develop"].push_access_level == "no one"
    error_message = "Invalid push_access_level on default branch"
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
    condition     = length(resource.gitlab_branch_protection.default["main"].allowed_to_push) == 1
    error_message = "Expected one user allowed to push on main"
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
