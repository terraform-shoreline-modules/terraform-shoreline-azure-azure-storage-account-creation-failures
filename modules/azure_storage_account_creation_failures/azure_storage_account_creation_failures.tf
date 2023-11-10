resource "shoreline_notebook" "azure_storage_account_creation_failures" {
  name       = "azure_storage_account_creation_failures"
  data       = file("${path.module}/data/azure_storage_account_creation_failures.json")
  depends_on = [shoreline_action.invoke_storage_account_validation,shoreline_action.invoke_azure_role_assignment]
}

resource "shoreline_file" "storage_account_validation" {
  name             = "storage_account_validation"
  input_file       = "${path.module}/data/storage_account_validation.sh"
  md5              = filemd5("${path.module}/data/storage_account_validation.sh")
  description      = "Check if the storage account name contains any naming conflicts or invalid characters. Ensure that the name adheres to Azure's naming conventions."
  destination_path = "/tmp/storage_account_validation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "azure_role_assignment" {
  name             = "azure_role_assignment"
  input_file       = "${path.module}/data/azure_role_assignment.sh"
  md5              = filemd5("${path.module}/data/azure_role_assignment.sh")
  description      = "Ensure that the user has the necessary permissions to create storage accounts. If not, grant the required permissions."
  destination_path = "/tmp/azure_role_assignment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_storage_account_validation" {
  name        = "invoke_storage_account_validation"
  description = "Check if the storage account name contains any naming conflicts or invalid characters. Ensure that the name adheres to Azure's naming conventions."
  command     = "`chmod +x /tmp/storage_account_validation.sh && /tmp/storage_account_validation.sh`"
  params      = ["STORAGE_ACCOUNT_NAME"]
  file_deps   = ["storage_account_validation"]
  enabled     = true
  depends_on  = [shoreline_file.storage_account_validation]
}

resource "shoreline_action" "invoke_azure_role_assignment" {
  name        = "invoke_azure_role_assignment"
  description = "Ensure that the user has the necessary permissions to create storage accounts. If not, grant the required permissions."
  command     = "`chmod +x /tmp/azure_role_assignment.sh && /tmp/azure_role_assignment.sh`"
  params      = ["SCOPE","RESOURCE_GROUP","STORAGE_ACCOUNT_NAME","USER_OR_GROUP_PRINCIPAL_NAME"]
  file_deps   = ["azure_role_assignment"]
  enabled     = true
  depends_on  = [shoreline_file.azure_role_assignment]
}

