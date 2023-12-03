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

resource "azuredevops_git_repository_file" "terraform_pipeline" {
  count = var.create_repo ? 1 : 0

  repository_id       = azuredevops_git_repository.this[0].id
  file                = "terraform-pipelines.yml"
  content             = file("${path.module}/default-files/terraform-pipelines.yml")
  branch              = var.repo_default_branch
  commit_message      = "Add terraform-pipelines.yml"
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

resource "azuredevops_build_definition" "this" {
  count = var.create_pipeline ? 1 : 0

  project_id = azuredevops_project.this.id
  name       = "Deploy with Terraform"

  repository {
    repo_type             = "TfsGit"
    repo_id               = azuredevops_git_repository.this[0].id
    branch_name           = azuredevops_git_repository.this[0].default_branch
    yml_path              = "terraform-pipelines.yml"
  }

  ci_trigger {
    use_yaml = true
  }

  variable_groups = [
    azuredevops_variable_group.this[0].id
  ]
}

# Authorise pipeline to access service endpoint
resource "azuredevops_pipeline_authorization" "this" {
  count = var.create_pipeline ? 1 : 0

  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_serviceendpoint_azurerm.this[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.this[0].id
}