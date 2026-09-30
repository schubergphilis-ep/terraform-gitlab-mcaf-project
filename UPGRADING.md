# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v2.0.0

### Key Changes

- This module now requires a minimum GitLab provider version of 19.0.0. See the [provider 19.0 upgrade guide](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/guides/version-19.0-upgrade) for the underlying changes.
- `gitlab_branch_protection` no longer sets `merge_access_level`, `push_access_level` and `unprotect_access_level`, which provider 19.0 rejects on GitLab Enterprise (Premium/Ultimate) instances. The role based access levels are now passed as `access_level` entries of the `allowed_to_merge`, `allowed_to_push` and `allowed_to_unprotect` attributes.
- Mirroring is now managed by a dedicated `gitlab_project_pull_mirror` resource. Provider 19.0 removed the `mirror`, `mirror_trigger_builds` and `mirror_overwrites_diverged_branches` attributes from `gitlab_project`.

### Variables

No variables were added, removed or renamed. `branch_protection.*.merge_access_level`, `branch_protection.*.push_access_level` and `branch_protection.*.unprotect_access_level` keep working and map onto the new `allowed_to_*` attributes.

### How to Upgrade

- Upgrade the GitLab provider to `>= 19.0.0` in the calling configuration.
- Run `terraform plan`. Expect an in-place update of every `gitlab_branch_protection` resource: the `*_access_level` attributes are removed from state and the equivalent `access_level` entry is added to `allowed_to_*`. GitLab keeps the same protection rules so no branches are unprotected during the apply.
- When `mirror = true`: a `gitlab_project_pull_mirror` resource is created and the `import_url*` attributes are removed from `gitlab_project`. GitLab keeps the existing mirror configuration; the new resource takes it over on apply.

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