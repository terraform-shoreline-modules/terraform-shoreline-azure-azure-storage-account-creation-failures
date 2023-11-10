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