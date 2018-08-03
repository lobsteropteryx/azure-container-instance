# Running a container in Azure Container Instances from an Azure Function

A demonstration of running an arbitrary container in Azure Container Instances (ACI), triggered via a Function.

## Summary

Demonstrates running an ephemeral container in ACI, triggered via an Azure Function.  The container image is pulled from a private Azure Container Registry.  This has a few advantages:

* Provides usage-only billing for code execution; the Function App runs on a Consumption plan, and ACI is billed per second of execution time
* Allows execution of arbitrary code (i.e., Ruby) that is not well-supported in Azure Functions

This is a working example that attempts to automate the configuration and deployment as much as possible.

## Prerequisites

You need [Terraform]() and the [Azure CLI]() installed:

```bash
brew install terraform
brew install
```

To configure Terraform, you need to set some environment variables for the Azure account you want to use:

```bash
#!/bin/sh
echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
export ARM_TENANT_ID=your_tenant_id

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public
```

The account you use needs to have `Contributor` access to the subscription where you want the function app to be created.

## Deployment

Once your environment is set up, you can run a single command:

```bash
./deploy.sh
```

This will create a resource group and a function app, together with an application insights instance and app service plan.  It will also create a container registry , and publish a function to trigger the ACI runs.
