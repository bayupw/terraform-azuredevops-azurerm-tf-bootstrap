module "azuredevops-bootstrap" {
  source  = "bayupw/azurerm-tf-bootstrap/azuredevops"
  version = "1.0.1"

  azuredevops_organisation = "<your-org-name>"
  azuredevops_token        = "<ADO personal token>"
  project_name             = "<ADO project name>"
  project_features = {
    "repositories" = "enabled"
    "pipelines"    = "enabled"
  }

  create_repo = true
  repo_name   = "my-tf-repo"

  create_service_endpoint = true
  service_endpoint_name   = "AzureRM Service Endpoint"
  tenantid                = "<00000000-0000-0000-0000-000000000000>"
  subscription_id         = "<00000000-0000-0000-0000-000000000000>"
  subscription_name       = "<My Azure Subscription Name>"

  create_storage         = true
  append_random_string   = true
  storage_rg_name        = "rg-terraform-state-tf"
  storage_account_name   = "stterraformstate"
  storage_container_name = "tfstate"
  terraform_blob_key     = "terraform.tfstate"

  create_variables_group = true
  create_pipeline        = true
  create_branch_policy   = true
  upload_tf_files        = true
  tf_file_path           = "tf-files/"
}