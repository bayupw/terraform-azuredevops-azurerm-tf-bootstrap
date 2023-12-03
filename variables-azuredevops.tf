variable "create_repo" {
  description = "Create Azure Devops Repo."
  type        = bool
  default     = true
}

variable "create_service_endpoint" {
  description = "Create Service endpoint."
  type        = bool
  default     = false
}

variable "create_pipeline" {
  description = "Create Azure DevOps pipeline."
  type        = bool
  default     = false
}

variable "create_variables_group" {
  description = "Create Variable groups in Azure DevOps pipeline."
  type        = bool
  default     = false
}

variable "upload_tf_files" {
  description = "Upload .tf files."
  type        = bool
  default     = false
}

variable "azuredevops_organisation_prefix" {
  description = "Azure DevOps URL prefix."
  type        = string
  default     = "https://dev.azure.com"
}

variable "azuredevops_organisation" {
  type = string
}

variable "azuredevops_token" {
  description = "Azure DevOps personal access token."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Azure DevOps Project name."
  type        = string
}

variable "project_description" {
  description = "Azure DevOps Project description."
  type        = string
  default     = null
}

variable "project_visibility" {
  description = "Visibility of the project."
  type        = string
  default     = "private"
}

variable "project_version_control" {
  description = "Version control system."
  type        = string
  default     = "Git"
}

variable "project_work_item_template" {
  description = "Work item template."
  type        = string
  default     = "Agile"
}

variable "project_features" {
  description = "Maps of features."
  type        = map(any)
  default = {
    "boards"       = "disabled"
    "repositories" = "disabled"
    "pipelines"    = "disabled"
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
  }
}

variable "repo_name" {
  description = "Azure Devops Repo name."
  type        = string
  default     = "my-repo"
}

variable "repo_default_branch" {
  description = "Azure Repo default branch."
  type        = string
  default     = "refs/heads/main"
}

variable "service_endpoint_name" {
  description = "Service endpoint name."
  type        = string
  default     = "Service endpoint"
}

variable "service_endpoint_description" {
  description = "Service endpoint description."
  type        = string
  default     = "Managed by Terraform"
}

variable "service_endpoint_authentication_scheme" {
  description = "Service endpoint authentication scheme."
  type        = string
  default     = "WorkloadIdentityFederation"
}

variable "tf_file_path" {
  description = ".tf file path."
  type        = string
  default     = "tf-files/"
}