# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v2.0.0

### Key Changes

- This module now requires a minimum GitLab provider version of 19.3.0. See the [GitLab provider 19.0 upgrade guide](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/guides/version-19.0-upgrade) for the underlying changes. Version 19.3.0 is required for `mr_default_title_template`.
- Mirroring is now managed by a dedicated `gitlab_project_pull_mirror` resource, as GitLab provider 19.0 removed the `mirror`, `mirror_trigger_builds` and `mirror_overwrites_diverged_branches` attributes from `gitlab_project`.
- GitLab provider 19.0 only accepts `merge_access_level` and `push_access_level` on GitLab CE instances, and only accepts `allowed_to_merge`, `allowed_to_push` and `allowed_to_unprotect` on GitLab EE instances. The module now reads the instance edition with the `gitlab_metadata` data source. On EE instances, the access levels are passed as `access_level` entries of the `allowed_to_*` attributes. On CE instances, they are passed as before.
- GitLab provider 19.0 removed `unprotect_access_level` from `gitlab_branch_protection`. On EE instances, `branch_protection.*.unprotect_access_level` is passed as an `access_level` entry of `allowed_to_unprotect`. CE instances have no equivalent, so setting it on a CE instance now fails.

### Variables

The following variable has been added:

- `mr_default_title_template` sets the template used for the default title of merge requests. It defaults to `null`.

No variables were removed or renamed.

### How to Upgrade

- Upgrade the GitLab provider to `>= 19.3.0` in the calling configuration.
- Run `terraform plan`. On EE instances, the provider upgrades the state of existing `gitlab_branch_protection` resources, and in most cases the plan shows no changes for them. When the push or merge rules of a protected branch in GitLab only list users or groups, the plan adds the access level configured in this module as an `access_level` entry (for example `no one` for push). Review these changes before applying.
- GitLab provider 19.3 manages `mr_default_title_template` on `gitlab_project`. If a project has a merge request title template that was configured outside of Terraform, set `mr_default_title_template` to keep it, otherwise it is removed on apply.
- GitLab provider 19.2 manages `issue_branch_template` on `gitlab_project`, which this module does not set. Values for this setting that were configured outside of Terraform are removed on apply.
- When `mirror = true`, a `gitlab_project_pull_mirror` resource is created and `import_url_username` and `import_url_password` are removed from `gitlab_project`. As described in the provider upgrade guide, the `gitlab_project` update removes the mirror and the `gitlab_project_pull_mirror` resource adds it back in the same apply.

## Upgrading to v1.0.0

### Key Changes

- This module now requires a minimum GitLab provider version of 17.10.0.

### Variables

The following variables have been removed in favor of the dedicated resource `gitlab_project_approval_rule`, which can be modified by the variable `var.project_approval_rule`:

- `approvals_before_merge`
- `use_group_settings`

The following variables have been changed in favor of newer, recommended attributes:

- `issues_enabled` is now `issues_access_level` and accepts either of the valid inputs: `disabled`, `private`, or `enabled`.
- `snippets_enabled` is now `snippets_access_level` and accepts either of the valid inputs: `disabled`, `private`, or `enabled`.
- `wiki_enabled` is now `wiki_access_level` and accepts either of the valid inputs: `disabled`, `private`, or `enabled`.

### How to Upgrade

- Remove all `approvals_before_merge` and `use_group_settings` inputs when using this module. Use the `project_approval_rule` variable instead when managing approval rules.
- Rename all instances of `issues_enabled` to `issues_access_level`
- Rename all instances of `snippets_enabled` to `snippets_access_level`
- Rename all instances of `wiki_enabled` to `wiki_access_level`
- If the value is `true` for any of the variables above, set the value to either `enabled` or `private` (see the [GitLab Projects API Reference](https://docs.gitlab.com/api/projects/#manage-projects) for more information about these values). If these variables are not defined when using the module, then no further action is needed as they all default to `disabled`.
