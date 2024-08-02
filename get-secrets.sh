#!/bin/bash

# Configuration
GITLAB_URL="https://gitlab.com"
PROJECT_ID="40235593"
JOB_NAME="retrieve_secret"

# Access the token from the environment variable
TOKEN="$GITLAB_TOKEN"

# Trigger the pipeline
RESPONSE=$(curl --silent --request POST --form "ref=main" --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/trigger/pipeline")
PIPELINE_ID=$(echo "$RESPONSE" | jq --raw-output '.id')

if [ -z "$PIPELINE_ID" ]; then
  echo "Pipeline ID not found"
  exit 1
fi

echo "Pipeline triggered with ID: $PIPELINE_ID"

# Wait for the pipeline to complete
while true; do
  STATUS=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines/$PIPELINE_ID" | jq --raw-output '.status')
  
  if [ "$STATUS" == "success" ]; then
    echo "Pipeline succeeded"
    break
  elif [ "$STATUS" == "failed" ]; then
    echo "Pipeline failed"
    exit 1
  else
    echo "Pipeline in progress... Waiting..."
    sleep 30
  fi
done

# Get the Job ID from the pipeline
JOB_ID=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines/$PIPELINE_ID/jobs" | jq --raw-output '.[] | select(.name=="'$JOB_NAME'") | .id')

if [ -z "$JOB_ID" ]; then
  echo "Job ID not found for job name: $JOB_NAME"
  exit 1
fi

# Download the artifact
curl --header "PRIVATE-TOKEN: $TOKEN" --output secret.env "$GITLAB_URL/api/v4/projects/$PROJECT_ID/jobs/$JOB_ID/artifacts/secret.env"

echo "Artifact downloaded successfully"