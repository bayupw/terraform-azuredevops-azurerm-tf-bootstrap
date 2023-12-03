# Terraform Azure DevOps Bootstrap Module

This Terraform module automates the process of setting up Azure DevOps for your Terraform Azure project. 
It creates an Azure DevOps project, repositories, AzureRM Service Connection, Azure Blob storage for Terraform state, variable groups, and pipelines for managing Terraform infrastructure.

## Prerequisites

Before using this module, ensure you have the following:

- [Azure DevOps account](https://azure.microsoft.com/services/devops/).
- [Azure Devops personal access token](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows).
- [Azure](https://portal.azure.com/) subscription with the necessary permissions and information (Subscription ID, Tenant ID).
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed locally.
- [Terraform](https://www.terraform.io/downloads.html) installed locally.

## Sample usage

```hcl
module "ado-bootstrap" {
  source = "../terraform-azuredevops-azurerm-tf-bootstrap"

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
  storage_rg_name        = "rg-terraform-state-tf"
  storage_account_name   = "stterraformstate"
  storage_container_name = "tfstate"
  terraform_blob_key     = "terraform.tfstate"

  create_variables_group = true
  create_pipeline        = true
  upload_tf_files        = true
  tf_file_path           = "tf-files/"
}
```

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/bayupw/terraform-azuredevops-azurerm-tf-bootstrap/issues/new) section.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/bayupw/terraform-azuredevops-azurerm-tf-bootstrap/tree/master/LICENSE) for full details.

## Reference and Useful Repos

- https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd