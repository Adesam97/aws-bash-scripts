#!/bin/bash

set -e

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Read .env file line by line
while IFS='=' read -r key value; do
    # Skip empty lines and comments
    if [ -z "$key" ] || [[ $key == \#* ]]; then
        continue
    fi
    
    # Remove any quotes from the value and leading/trailing spaces
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["'"'"']*//' -e 's/["'"'"']*$//')
    key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    if aws ssm get-parameter --name "$key" &>/dev/null; then
       existing_value=$(aws ssm get-parameter --name "$key" --with-decryption --query "Parameter.Value" --output text)
        if [ "$existing_value" == "$value" ]; then
            echo "✅ Parameter '$key' already exists with the same value. Skipping."
            continue
        else
            echo "🔁 Parameter '$key' exists but with a different value. Overwriting..."
        fi
    fi 
    
    # Create SSM parameter
    echo "Creating parameter: $key"
    aws ssm put-parameter \
        --name "$key" \
        --value "$value" \
        --type "SecureString" \
        --tier "Standard" \
        --key-id "alias/aws/ssm" \
        --overwrite

    if [ $? -eq 0 ]; then
        echo "Successfully created parameter: $key"
    else
        echo "Error creating parameter: $key"
    fi
done < .env

echo "Parameter creation complete"