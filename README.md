
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Azure Storage Account Creation Failures

This incident type refers to the occurrence of errors while trying to create a new Azure Storage Account. The error could be due to naming conflicts or invalid characters in the storage account name, or insufficient quotas for storage accounts in the Azure subscription. This can cause disruption to the storage and retrieval of data, affecting the overall functionality of the Azure Storage Account.

### Parameters

```shell
export RESOURCE_GROUP="PLACEHOLDER"
export STORAGE_ACCOUNT_NAME="PLACEHOLDER"
export USER_OR_GROUP_PRINCIPAL_NAME="PLACEHOLDER"
export SCOPE="PLACEHOLDER"
```

## Debug

### Verify Azure CLI Version

```shell
az --version
```

### List all storage accounts in a resource group

```shell
az storage account list --resource-group ${RESOURCE_GROUP} --output table
```

### Check if the storage account name is available

```shell
az storage account check-name --name ${STORAGE_ACCOUNT_NAME} --query "nameAvailable"
```

### Check Azure Activity Log for Storage Account Creation Events

```shell
az monitor activity-log list --resource-group ${RESOURCE_GROUP} --offset 1h
```

### Check if the storage account name contains any naming conflicts or invalid characters. Ensure that the name adheres to Azure's naming conventions.

```shell
#!/bin/bash

# The name of the Azure storage account to be created
storage_account_name=${STORAGE_ACCOUNT_NAME}

# Check if the storage account name contains any invalid characters
if [[ $storage_account_name =~ [^a-z0-9] ]]; then
  echo "Invalid characters found in the storage account name."
  exit 1
fi

# Ensure that the storage account name adheres to Azure's naming conventions
if [[ ${#storage_account_name} -lt 3 || ${#storage_account_name} -gt 24 ]]; then
  echo "The storage account name must be between 3 and 24 characters long."
  exit 1
fi

if [[ $storage_account_name =~ ^[0-9] ]]; then
  echo "The storage account name cannot start with a number."
  exit 1
fi

if [[ $storage_account_name =~ -[0-9] ]]; then
  echo "The storage account name cannot contain a hyphen followed by a number."
  exit 1
fi

if [[ $storage_account_name =~ [A-Z] ]]; then
  echo "The storage account name must be in lowercase."
  exit 1
fi

echo "The storage account name adheres to Azure's naming conventions."
exit 0
```
## Repair

### Ensure that the user has the necessary permissions to create storage accounts. If not, grant the required permissions.

```shell
#!/bin/bash

# Set the Azure subscription ID and storage account name
resource_group=${RESOURCE_GROUP}
storage_account_name=${STORAGE_ACCOUNT_NAME}
user_or_group_principal_name=${USER_OR_GROUP_PRINCIPAL_NAME}
scope=${SCOPE}

# Set the role assignment name and role definition ID
role_assignment_name="Storage Account Contributor"
role_definition_id=$(az role definition list --name "$role_assignment_name" --query '[].id' --output tsv --resource-group $resource_group)

# Get the object ID of the user or group that needs permissions
object_id=$(az ad user show --id $user_or_group_principal_name --query 'id' --output tsv)

# Assign the role to the user or group
az role assignment create --role $role_definition_id --assignee-object-id $object_id --scope $scope
```