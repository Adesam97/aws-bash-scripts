#!/bin/bash

set -e

if aws --version &>/dev/null; then
   echo "✅ AWS CLI is already installed."
   aws --version
else
   echo "⚠️ AWS CLI is not installed. let's set up"
   sudo apt update -y
   sudo apt install -y curl unzip
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install   #install awscli
   aws --version
   rm -rf awscliv2.zip aws
fi
rm -rf awscliv2.zip aws

echo "Let's check if you've configured aws-cli"
if aws sts get-caller-identity &>/dev/null; then
   echo "✅ AWS CLI is already configured."
   aws sts get-caller-identity
   exit 0
else
   echo "⚠️ AWS CLI is not configured. Let's configure!"
fi
#take input for secret and access key
read -p "Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
read -p "Enter your AWS Default Region (e.g., us-east-1): " AWS_DEFAULT_REGION
read -p "Enter your AWS output format (json, table, text): " AWS_OUTPUT_FORMAT
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_DEFAULT_REGION"
aws configure set output "$AWS_OUTPUT_FORMAT"

echo ""
echo "============================"
echo "AWS CLI configured successfully!"
echo "============================"
aws sts get-caller-identity
