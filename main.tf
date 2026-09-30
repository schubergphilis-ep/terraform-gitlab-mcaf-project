locals {
  branch_protection = merge({
    (var.default_branch) = {
      allow_force_push             = false
      code_owner_approval_required = false
      groups_allowed_to_merge      = []
      groups_allowed_to_push       = []
      groups_allowed_to_unprotect  = []
      merge_access_level           = "developer"
      push_access_level            = "no one"
      unprotect_access_level       = null
      users_allowed_to_merge       = []
      users_allowed_to_push        = []
      users_allowed_to_unprotect   = []
    }
  }, var.branch_protection)

  // List of users to look up
  users = toset(flatten([for branch, settings in local.branch_protection :
    distinct(concat(settings.users_allowed_to_merge, settings.users_allowed_to_push, settings.users_allowed_to_unprotect))
  ]))

  // List of groups to look up
  groups = toset(flatten([for branch, settings in local.branch_protection :
    distinct(concat(settings.groups_allowed_to_merge, settings.groups_allowed_to_push, settings.groups_allowed_to_unprotect))
  ]))

  pipeline_schedule_enabled = var.pipeline_schedule != null ? true : false
}

################################################################################
# Repository
################################################################################

data "gitlab_group" "default" {
  full_path = var.namespace
}

resource "gitlab_project" "default" {
  name                                             = var.name
  archive_on_destroy                               = var.archive_on_destroy
  ci_config_path                                   = var.ci_config_path
  ci_default_git_depth                             = var.ci_default_git_depth
  default_branch                                   = var.default_branch
  description                                      = var.description
  import_url                                       = var.mirror ? null : var.import_url # Mirrored repositories are configured through gitlab_project_pull_mirror
  import_url_password                              = var.mirror ? null : var.import_url_password
  import_url_username                              = var.mirror ? null : var.import_url_username
  initialize_with_readme                           = var.import_url != null ? null : var.initialize_with_readme
  issues_access_level                              = var.issues_access_level
  namespace_id                                     = data.gitlab_group.default.id
  only_allow_merge_if_all_discussions_are_resolved = var.only_allow_merge_if_all_discussions_are_resolved
  only_allow_merge_if_pipeline_succeeds            = var.only_allow_merge_if_pipeline_succeeds
  remove_source_branch_after_merge                 = var.remove_source_branch_after_merge
  snippets_access_level                            = var.snippets_access_level
  squash_option                                    = var.squash_option
  visibility_level                                 = var.visibility
  wiki_access_level                                = var.wiki_access_level

  push_rules {
    commit_message_regex    = var.commit_message_regex
    prevent_secrets         = var.prevent_secrets
    reject_unsigned_commits = var.reject_unsigned_commits
  }
}

resource "gitlab_project_pull_mirror" "default" {
  count = var.mirror ? 1 : 0

  project                             = gitlab_project.default.id
  url                                 = var.import_url
  auth_user                           = var.import_url_username
  auth_password                       = var.import_url_password
  mirror_trigger_builds               = var.mirror_trigger_builds
  mirror_overwrites_diverged_branches = var.mirror_overwrites_diverged_branches
}

resource "gitlab_project_variable" "default" {
  for_each = var.cicd_variables

  project       = gitlab_project.default.id
  key           = each.key
  value         = each.value.value
  protected     = each.value.protected
  hidden        = each.value.hidden
  masked        = each.value.masked
  raw           = each.value.raw
  variable_type = each.value.variable_type
  description   = each.value.description
}

resource "gitlab_project_level_mr_approvals" "default" {
  # Do not configure approvals if we are mirroring from another repository and overwriting diverged branches.
  count = var.mirror && var.mirror_overwrites_diverged_branches ? 0 : 1

  project                                        = gitlab_project.default.id
  reset_approvals_on_push                        = var.merge_request_approval_rule.reset_approvals_on_push
  disable_overriding_approvers_per_merge_request = var.merge_request_approval_rule.disable_overriding_approvers_per_merge_request
  merge_requests_author_approval                 = var.merge_request_approval_rule.merge_requests_author_approval
  merge_requests_disable_committers_approval     = var.merge_request_approval_rule.merge_requests_disable_committers_approval
}

data "gitlab_user" "project_approval_rule_users" {
  for_each = try(toset(var.project_approval_rule.users), [])

  username = each.value
}

data "gitlab_group" "project_approval_rule_groups" {
  for_each = try(toset(var.project_approval_rule.groups), [])

  full_path = each.value
}

resource "gitlab_project_approval_rule" "default" {
  # Do not configure approvals if we are mirroring from another repository and overwriting diverged branches.
  count = var.mirror && var.mirror_overwrites_diverged_branches ? 0 : 1

  project                           = gitlab_project.default.id
  name                              = var.project_approval_rule.name
  approvals_required                = var.project_approval_rule.approvals_required
  applies_to_all_protected_branches = var.project_approval_rule.applies_to_all_protected_branches
  protected_branch_ids              = try([for branch in var.project_approval_rule.protected_branches : gitlab_branch_protection.default[branch].branch_protection_id], null)
  user_ids                          = try([for user in var.project_approval_rule.users : data.gitlab_user.project_approval_rule_users[user].id], null)
  group_ids                         = try([for group in var.project_approval_rule.groups : data.gitlab_group.project_approval_rule_groups[group].id], null)
}

################################################################################
# Branch protection
################################################################################

data "gitlab_user" "users" {
  for_each = local.users

  username = each.value
}

data "gitlab_group" "groups" {
  for_each = local.groups

  full_path = each.value
}

resource "gitlab_branch_protection" "default" {
  # Do not configure branch protection if we are mirroring from another repository and overwriting diverged branches.
  for_each = var.mirror && var.mirror_overwrites_diverged_branches ? {} : local.branch_protection

  #checkov:skip=CKV_GLB_2: False positive, default is true
  allow_force_push             = try(each.value.allow_force_push, false)
  branch                       = each.key
  code_owner_approval_required = each.value.code_owner_approval_required
  project                      = gitlab_project.default.id

  # GitLab provider >= 19.0 no longer accepts merge_access_level, push_access_level and unprotect_access_level on
  # Enterprise instances. The role based access level is passed as an entry of the allowed_to_* attributes instead.
  allowed_to_merge = concat(
    [{ access_level = each.value.merge_access_level }],
    [for user in each.value.users_allowed_to_merge : { user_id = data.gitlab_user.users[user].id }],
    [for group in each.value.groups_allowed_to_merge : { group_id = data.gitlab_group.groups[group].id }],
  )

  allowed_to_push = concat(
    [{ access_level = each.value.push_access_level }],
    [for user in each.value.users_allowed_to_push : { user_id = data.gitlab_user.users[user].id }],
    [for group in each.value.groups_allowed_to_push : { group_id = data.gitlab_group.groups[group].id }],
  )

  allowed_to_unprotect = length(concat(
    each.value.unprotect_access_level != null ? [each.value.unprotect_access_level] : [],
    each.value.users_allowed_to_unprotect,
    each.value.groups_allowed_to_unprotect,
    )) == 0 ? null : concat(
    each.value.unprotect_access_level != null ? [{ access_level = each.value.unprotect_access_level }] : [],
    [for user in each.value.users_allowed_to_unprotect : { user_id = data.gitlab_user.users[user].id }],
    [for group in each.value.groups_allowed_to_unprotect : { group_id = data.gitlab_group.groups[group].id }],
  )
}

################################################################################
# Pipeline schedule
################################################################################

resource "gitlab_pipeline_schedule" "default" {
  for_each = local.pipeline_schedule_enabled ? { create = true } : {}

  active         = var.pipeline_schedule.active
  project        = gitlab_project.default.id
  description    = var.pipeline_schedule.description
  ref            = var.pipeline_schedule.ref
  cron           = var.pipeline_schedule.cron
  cron_timezone  = var.pipeline_schedule.cron_timezone
  take_ownership = var.pipeline_schedule.take_ownership
}
