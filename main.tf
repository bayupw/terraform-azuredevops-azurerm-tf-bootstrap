################################################################################
# Azure DevOps
################################################################################

resource "azuredevops_project" "this" {
  name               = var.project_name
  description        = var.project_description
  visibility         = var.project_visibility
  version_control    = var.project_version_control
  work_item_template = var.project_work_item_template
  features           = var.project_features
}

resource "azuredevops_serviceendpoint_azurerm" "this" {
  count = var.create_service_endpoint ? 1 : 0

  project_id                             = azuredevops_project.this.id
  service_endpoint_name                  = var.service_endpoint_name
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  description                            = var.service_endpoint_description
  azurerm_spn_tenantid                   = var.tenantid
  azurerm_subscription_id                = var.subscription_id
  azurerm_subscription_name              = var.subscription_name
}

resource "azuredevops_git_repository" "this" {
  count = var.create_repo ? 1 : 0

  project_id     = azuredevops_project.this.id
  name           = var.repo_name
  default_branch = var.repo_default_branch

  initialization {
    init_type = "Clean"
  }

  # Ignore changes to initialization to support importing existing repositories
  # Given that a repo now exists, either imported into terraform state or created by terraform,
  # we don't care for the configuration of initialization against the existing resource
  lifecycle { ignore_changes = [initialization] }
}

resource "azuredevops_git_repository_file" "gitignore" {
  count = var.create_repo ? 1 : 0

  repository_id       = azuredevops_git_repository.this[0].id
  file                = ".gitignore"
  content             = file("${path.module}/default-files/.gitignore")
  branch              = var.repo_default_branch
  commit_message      = "Add .gitignore"
  overwrite_on_create = false

  lifecycle { ignore_changes = [content, commit_message, file] }
}

resource "azuredevops_git_repository_file" "terraform_plan" {
  count = var.create_repo ? 1 : 0

  repository_id       = azuredevops_git_repository.this[0].id
  file                = "pipeline/terraform-plan.yml"
  content             = file("${path.module}/default-files/terraform-plan.yml")
  branch              = var.repo_default_branch
  commit_message      = "Add terraform-plan.yml"
  overwrite_on_create = false

  lifecycle { ignore_changes = [content, commit_message, file] }
}

resource "azuredevops_git_repository_file" "terraform_apply" {
  count = var.create_repo ? 1 : 0

  repository_id       = azuredevops_git_repository.this[0].id
  file                = "pipeline/terraform-apply.yml"
  content             = file("${path.module}/default-files/terraform-apply.yml")
  branch              = var.repo_default_branch
  commit_message      = "Add terraform-apply.yml"
  overwrite_on_create = false

  lifecycle { ignore_changes = [content, commit_message, file] }
}

resource "azuredevops_git_repository_file" "tf_files" {
  for_each = var.upload_tf_files ? fileset("${path.root}/${var.tf_file_path}", "*.tf") : []

  repository_id  = azuredevops_git_repository.this[0].id
  file           = each.value
  content        = file("${path.root}/${var.tf_file_path}${each.value}")
  branch         = var.repo_default_branch
  commit_message = "Upload tf files"

  lifecycle { ignore_changes = [content, commit_message, file] }
}


resource "azuredevops_variable_group" "this" {
  count = var.create_variables_group ? 1 : 0

  project_id   = azuredevops_project.this.id
  name         = "shared"
  description  = "Shared Variable Group Description"
  allow_access = false

  variable {
    name  = "BACKEND_RESOURCE_GROUP"
    value = azurerm_resource_group.this[0].name
  }

  variable {
    name  = "BACKEND_STORAGE_ACCOUNT"
    value = azurerm_storage_account.this[0].name
  }

  variable {
    name  = "BACKEND_STORAGE_CONTAINER"
    value = azurerm_storage_container.this[0].name
  }

  variable {
    name  = "BACKEND_KEY"
    value = var.terraform_blob_key
  }

  variable {
    name  = "SERVICE_CONNECTION"
    value = azuredevops_serviceendpoint_azurerm.this[0].service_endpoint_name
  }
}

resource "azuredevops_build_definition" "plan" {
  count = var.create_pipeline ? 1 : 0

  project_id = azuredevops_project.this.id
  name       = "Terraform plan"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this[0].id
    branch_name = azuredevops_git_repository.this[0].default_branch
    yml_path    = "pipeline/terraform-plan.yml"
  }

  ci_trigger {
    use_yaml = true
  }

  variable_groups = [
    azuredevops_variable_group.this[0].id
  ]
}

resource "azuredevops_build_definition" "apply" {
  count = var.create_pipeline ? 1 : 0

  project_id = azuredevops_project.this.id
  name       = "Terraform apply"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this[0].id
    branch_name = azuredevops_git_repository.this[0].default_branch
    yml_path    = "pipeline/terraform-apply.yml"
  }

  ci_trigger {
    use_yaml = true
  }

  variable_groups = [
    azuredevops_variable_group.this[0].id
  ]
}

resource "azuredevops_pipeline_authorization" "plan" {
  count = var.create_pipeline ? 1 : 0

  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_serviceendpoint_azurerm.this[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.plan[0].id
}

resource "azuredevops_pipeline_authorization" "apply" {
  count = var.create_pipeline ? 1 : 0

  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_serviceendpoint_azurerm.this[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.apply[0].id
}

resource "azuredevops_branch_policy_min_reviewers" "this" {
  count = var.create_branch_policy ? 1 : 0

  project_id = azuredevops_project.this.id
  enabled    = true
  blocking   = true

  settings {
    reviewer_count     = 1
    submitter_can_vote = true

    scope {
      repository_id  = azuredevops_git_repository.this[0].id
      repository_ref = azuredevops_git_repository.this[0].default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository_file.gitignore,
    azuredevops_git_repository_file.terraform_plan,
    azuredevops_git_repository_file.terraform_apply,
    azuredevops_git_repository_file.tf_files
  ]
}

resource "azuredevops_branch_policy_comment_resolution" "this" {
  count = var.create_branch_policy ? 1 : 0

  project_id = azuredevops_project.this.id
  enabled    = true
  blocking   = true

  settings {

    scope {
      repository_id  = azuredevops_git_repository.this[0].id
      repository_ref = azuredevops_git_repository.this[0].default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository_file.gitignore,
    azuredevops_git_repository_file.terraform_plan,
    azuredevops_git_repository_file.terraform_apply,
    azuredevops_git_repository_file.tf_files
  ]
}

resource "azuredevops_branch_policy_build_validation" "this" {
  count = var.create_branch_policy ? 1 : 0

  project_id = azuredevops_project.this.id
  enabled    = true
  blocking   = true

  settings {
    display_name        = "Build validation policy"
    build_definition_id = azuredevops_build_definition.plan[0].id
    valid_duration      = 720

    scope {
      repository_id  = azuredevops_git_repository.this[0].id
      repository_ref = azuredevops_git_repository.this[0].default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository_file.gitignore,
    azuredevops_git_repository_file.terraform_plan,
    azuredevops_git_repository_file.terraform_apply,
    azuredevops_git_repository_file.tf_files
  ]
}

################################################################################
# AzureRM
################################################################################

resource "random_string" "this" {
  count = var.append_random_string ? 1 : 0

  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  count = var.create_storage ? 1 : 0

  name     = var.storage_rg_name
  location = var.location
}

resource "azurerm_storage_account" "this" {
  count = var.create_storage ? 1 : 0

  name                            = "${var.storage_account_name}${random_string.this[0].result}"
  resource_group_name             = azurerm_resource_group.this[0].name
  location                        = azurerm_resource_group.this[0].location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication
  allow_nested_items_to_be_public = false

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "this" {
  count = var.create_storage ? 1 : 0

  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.this[0].name
  container_access_type = "private"
}