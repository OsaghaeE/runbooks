#!/bin/bash

# CONFIGURATION (EDIT THESE)
RESOURCE_GROUP="RG_Monitoring"
AUTOMATION_ACCOUNT="eastusvau-6pt-asr-automationaccount"
LOCATION="East US"
SUBSCRIPTION_ID="42dff4cd-ba03-4206-94c5-721389b64c1e"

# Runbook names and script files
START_RUNBOOK_NAME="Start-DevVMs"
SHUTDOWN_RUNBOOK_NAME="Shutdown-DevVMs"
START_SCRIPT_FILE="Start-DevVMs.ps1"
SHUTDOWN_SCRIPT_FILE="Shutdown-DevVMs.ps1"

# Login
az login
az account set --subscription "$SUBSCRIPTION_ID"

# Function to create and publish a runbook
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

  echo "Uploading script for: $NAME"
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

# Function to create a daily schedule
create_schedule() {
  local SCHEDULE_NAME=$1
  local HOUR=$2
  local MINUTE=$3

  echo "Creating schedule: $SCHEDULE_NAME"
  az automation schedule create \
    --resource-group "$RESOURCE_GROUP" \
    --automation-account-name "$AUTOMATION_ACCOUNT" \
    --name "$SCHEDULE_NAME" \
    --start-time "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --frequency Day \
    --interval 1 \
    --time-zone "Australia/Sydney Time" \
    --hour $HOUR \
    --minute $MINUTE
}

# Function to link runbook to schedule
link_runbook_to_schedule() {
  local RUNBOOK=$1
  local SCHEDULE=$2

  echo "Linking $RUNBOOK to schedule $SCHEDULE"
  az automation runbook schedule create \
    --resource-group "$RESOURCE_GROUP" \
    --automation-account-name "$AUTOMATION_ACCOUNT" \
    --runbook-name "$RUNBOOK" \
    --schedule-name "$SCHEDULE"
}

# Create runbooks
create_runbook "$START_RUNBOOK_NAME" "$START_SCRIPT_FILE"
create_runbook "$SHUTDOWN_RUNBOOK_NAME" "$SHUTDOWN_SCRIPT_FILE"

# Create schedules
create_schedule "StartDevVMsSchedule" 7 00
create_schedule "ShutdownDevVMsSchedule" 18 00

# Link runbooks to schedules
link_runbook_to_schedule "$START_RUNBOOK_NAME" "StartDevVMsSchedule"
link_runbook_to_schedule "$SHUTDOWN_RUNBOOK_NAME" "ShutdownDevVMsSchedule"

echo "Runbooks deployed, scheduled, and linked successfully!"
