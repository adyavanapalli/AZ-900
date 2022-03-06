# Terraform Azure with GitHub Actions

[![Terraform Apply](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/terraform-apply.yml/badge.svg)](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/terraform-apply.yml) [![Terraform Destroy](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/terraform-destroy.yml/badge.svg)](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/terraform-destroy.yml)

A project for experimenting with Terraform on Azure hosted on GitHub. This
repository serves as the sister repository for
[Terraform Azure with Azure DevOps](https://dev.azure.com/starsandmanifolds/TerraformAzureWithAzureDevOps).

## Notice

To prevent excessive resource consumption, there is a
[`terraform-destroy.yml`](.github/workflows/terraform-destroy.yml)
GitHub Actions workflow that runs at an appropriate schedule to destroy any
resources created through any of the other workflows.
