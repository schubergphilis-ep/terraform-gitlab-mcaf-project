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

run "import_url" {
  variables {
    name       = "basic-${run.setup.random_string}"
    namespace  = "basic-${run.setup.random_string}"
    import_url = "https://example.com/repo.git"
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.gitlab_project.default.import_url == "https://example.com/repo.git"
    error_message = "Expected import_url to be: \"https://example.com/repo.git\", got: \"${resource.gitlab_project.default.import_url}\""
  }

  assert {
    condition     = length(resource.gitlab_project_pull_mirror.default) == 0
    error_message = "Expected no pull mirror when mirror is false"
  }
}

run "import_url_with_credentials" {
  variables {
    name                = "basic-${run.setup.random_string}"
    namespace           = "basic-${run.setup.random_string}"
    import_url          = "https://example.com/repo.git"
    import_url_username = "user"
    import_url_password = "password"
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.gitlab_project.default.import_url == "https://example.com/repo.git"
    error_message = "Expected import_url to be: \"https://example.com/repo.git\", got: \"${resource.gitlab_project.default.import_url}\""
  }

  assert {
    condition     = resource.gitlab_project.default.import_url_username == "user"
    error_message = "Expected import_url_username to be: \"user\", got: \"${resource.gitlab_project.default.import_url_username}\""
  }

  assert {
    condition     = resource.gitlab_project.default.import_url_password == "password"
    error_message = "Expected import_url_password to be: \"password\", got: \"${nonsensitive(resource.gitlab_project.default.import_url_password)}\""
  }
}

run "import_url_with_mirror_true" {
  variables {
    name       = "basic-${run.setup.random_string}"
    namespace  = "basic-${run.setup.random_string}"
    import_url = "https://example.com/repo.git"
    mirror     = true
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].url == "https://example.com/repo.git"
    error_message = "Expected pull mirror url to be: \"https://example.com/repo.git\""
  }

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].mirror_trigger_builds == true
    error_message = "Expected mirror_trigger_builds to be: true"
  }

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].mirror_overwrites_diverged_branches == true
    error_message = "Expected mirror_overwrites_diverged_branches to be: true"
  }
}

run "mirror_with_credentials" {
  variables {
    name                                = "basic-${run.setup.random_string}"
    namespace                           = "basic-${run.setup.random_string}"
    import_url                          = "https://example.com/repo.git"
    import_url_username                 = "user"
    import_url_password                 = "password"
    mirror                              = true
    mirror_trigger_builds               = false
    mirror_overwrites_diverged_branches = false
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].auth_user == "user"
    error_message = "Expected pull mirror auth_user to be: \"user\", got: \"${resource.gitlab_project_pull_mirror.default[0].auth_user}\""
  }

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].auth_password == "password"
    error_message = "Expected pull mirror auth_password to be: \"password\""
  }

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].mirror_trigger_builds == false
    error_message = "Expected mirror_trigger_builds to be: false"
  }

  assert {
    condition     = resource.gitlab_project_pull_mirror.default[0].mirror_overwrites_diverged_branches == false
    error_message = "Expected mirror_overwrites_diverged_branches to be: false"
  }

  assert {
    condition     = resource.gitlab_project.default.import_url_username == null && resource.gitlab_project.default.import_url_password == null
    error_message = "Expected import_url credentials to be moved from the project to the pull mirror"
  }
}

run "mirror_true_without_import_url" {
  variables {
    name      = "basic-${run.setup.random_string}"
    namespace = "basic-${run.setup.random_string}"
    mirror    = true
  }

  module {
    source = "./"
  }

  command = plan

  expect_failures = [
    var.mirror,
  ]
}
