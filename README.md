# Terraform Azure DevOps Bootstrap Module

This Terraform module automates the process of setting up Azure DevOps for your Terraform Azure project. 
The module creates:
- Azure DevOps project
- Azure repo with branch policies
- AzureRM Service Connection
- Azure Blob storage for Terraform state-
- Variable groups
- Azure DevOps pipelines
- Publish JUnit test result XML to Azure DevOps pipelines

## Prerequisites

Before using this module, ensure you have the following:

- [Azure DevOps account](https://azure.microsoft.com/services/devops/).
- [Azure Devops personal access token](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows).
- [Microsoft DevLabs Terraform Task](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks).
- [Azure](https://portal.azure.com/) subscription with the necessary permissions and information (Subscription ID, Tenant ID).
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed locally.
- [Terraform](https://www.terraform.io/downloads.html) installed locally.

## Sample usage

```hcl
module "azuredevops-bootstrap" {
  source  = "bayupw/azurerm-tf-bootstrap/azuredevops"
  version = "1.0.0"

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
```

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/bayupw/terraform-azuredevops-azurerm-tf-bootstrap/issues/new) section.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/bayupw/terraform-azuredevops-azurerm-tf-bootstrap/tree/master/LICENSE) for full details.

## Reference and Useful Repos

- https://learn.microsoft.com/en-us/samples/azure-samples/github-terraform-oidc-ci-cd/github-terraform-oidc-ci-cd/
- https://github.com/microsoft/azure-pipelines-terraform/blob/main/Tasks/TerraformTask/TerraformTaskV4/README.md