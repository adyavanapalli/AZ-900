# Terraform Azure with GitHub Actions

[![CI](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/ci.yml/badge.svg)](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/ci.yml) [![Destroy](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/destroy.yml/badge.svg)](https://github.com/adyavanapalli/TerraformAzureWithGitHubActions/actions/workflows/destroy.yml)

A project for experimenting with Terraform on Azure hosted on GitHub. This
repository serves as the sister repository for
[Terraform Azure with Azure DevOps](https://dev.azure.com/starsandmanifolds/TerraformAzureWithAzureDevOps).

## Notice

To prevent excessive resource consumption, there is a
[`destroy.yml`](.github/workflows/destroy.yml)
GitHub Actions workflow that runs at an appropriate schedule to destroy any
resources created through any of the other workflows.
