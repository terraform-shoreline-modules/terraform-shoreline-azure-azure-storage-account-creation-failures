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