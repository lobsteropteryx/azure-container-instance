#!/usr/bin/env bash
set -e

APP_NAME=azure-container-instance
RESOURCE_GROUP=azure-container-instance

# Create function app, container repository, etc.
terraform apply \
-var "subscription_id=${ARM_SUBSCRIPTION_ID}" \
-auto-approve

# Use managed service identity for the function app
az functionapp identity remove -g ${RESOURCE_GROUP} -n ${APP_NAME}
az functionapp identity assign -g ${RESOURCE_GROUP} -n ${APP_NAME} --role Contributor --scope /subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}

# Grant access on the container repository to the managed service identity
az role assignment create \
  --assignee $(az functionapp identity show -n ${APP_NAME} -g ${RESOURCE_GROUP} --query principalId --output tsv) \
  --role READER \
  --scope $(az acr show --name azurecontainerinstance --query id --output tsv)

# Publish the function code
rm -f function.zip

pushd Test/StartContainerInstance
npm install
popd

pushd Test
zip ../function.zip -r .
popd

az functionapp deployment source config-zip \
    -g "${RESOURCE_GROUP}" \
    -n "${APP_NAME}" \
    --src function.zip