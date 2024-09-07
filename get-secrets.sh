#!/bin/bash

source ~/.secrets

# List of variable keys you want to retrieve
VARIABLE_KEYS=("GITHUB_PAT" 
                "MEGA_EMAIL" "MEGA_PASSWORD" 
                "POSTGRES_USER" "POSTGRES_PASSWORD"
                "DROPBOX_EMAIL" "DROPBOX_PASSWORD"
                "GGL_EMAIL" "GGL_PASSWORD"
                "MSFT_EMAIL" "MSFT_PASSWORD"
                )

# Function to get variable value
get_variable_value() {
    local variable_key="$1"
    local response=$(curl --silent --header "PRIVATE-TOKEN: $GITLAB_PAT" "https://gitlab.com/api/v4/projects/40235593/variables/$variable_key")

    # Check if the response contains an error
    if echo "$response" | jq -e .error >/dev/null; then
        echo "Error retrieving variable $variable_key: $(echo $response | jq -r .error)"
        exit 1
    fi
    
    # Extract the value using jq
    local variable_value=$(echo "$response" | jq -r '.value')
    
    # Check if the variable value was retrieved successfully
    if [ -z "$variable_value" ]; then
        echo "Failed to retrieve the value of the variable: $variable_key"
        exit 1
    fi
    echo "$variable_value"
}

# Loop through each variable key and get its value
for key in "${VARIABLE_KEYS[@]}"; do
    value=$(get_variable_value "$key")
    echo "Value retreaved for : $key"
    # Check if the variable is already in .secrets
    if grep -q "^$key=" ~/.secrets; then
        # Replace the existing variable
        sed -i "s|^$key=.*|$key='$value'|" ~/.secrets
    else
        # Append the new variable
        echo "$key='$value'" >> ~/.secrets
    fi
done

# Check if the ~/.secrets is sourced in ~/.zshrc
if ! grep -Fxq "source ~/.secrets" ~/.zshrc; then
    # If not, add the line to the file
    echo "source ~/.secrets" >> ~/.zshrc
    echo "~/.secrets successfuly sourced in ~/.zshrc file."
else
    echo "~/.secrets already sourced in ~/.zshrc file."
fi