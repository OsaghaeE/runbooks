#!/bin/bash

# Required parameters (edit these)
RESOURCE_GROUP="RG_Monitoring"
AUTOMATION_ACCOUNT="eastusvau-6pt-asr-automationaccount"
LOCATION="East US"
SUBSCRIPTION_ID="42dff4cd-ba03-4206-94c5-721389b64c1e"

# Configuration PowerShell Files to implement the shutdown and startup
START_RUNBOOK_NAME="Start-DevVMs"
SHUTDOWN_RUNBOOK_NAME="Shutdown-DevVMs"
START_SCRIPT_FILE="Start-DevVMs.ps1"
SHUTDOWN_SCRIPT_FILE="Shutdown-DevVMs.ps1"

# Login and set subscription
az login
az account set --subscription "$SUBSCRIPTION_ID"

# Function to deploy a runbook
create_runbook() {
  local NAME=$1
  local FILE=$2

  echo "Creating runbook: $NAME"
  az automation runbook create \
    --resource-group "$RESOURCE_GROUP" \
    --automation-account-name "$AUTOMATION_ACCOUNT" \
    --name "$NAME" \
    --type "PowerShellWorkflow" \
    --location "$LOCATION"

  echo "Uploading content for: $NAME"
  az automation runbook replace-content \
    --resource-group "$RESOURCE_GROUP" \
    --automation-account-name "$AUTOMATION_ACCOUNT" \
    --name "$NAME" \
    --content @"$FILE"

  echo "Publishing runbook: $NAME"
  az automation runbook publish \
    --resource-group "$RESOURCE_GROUP" \
    --automation-account-name "$AUTOMATION_ACCOUNT" \
    --name "$NAME"
}

# Deploy both runbooks
create_runbook "$START_RUNBOOK_NAME" "$START_SCRIPT_FILE"
create_runbook "$SHUTDOWN_RUNBOOK_NAME" "$SHUTDOWN_SCRIPT_FILE"

echo "Runbooks created and published successfully."
