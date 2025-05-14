#!/bin/bash

set -e
OS=$(uname -s)

get_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo ""
  fi
}

if aws --version &>/dev/null; then
   echo "✅ AWS CLI is already installed."
   aws --version
else
   echo "⚠️ AWS CLI is not installed. let's set up!"
   #linux 
   if [[ "$OS" == "Linux" ]]; then
      DISTRO=$(get_distro)
      if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        sudo apt update -y
        sudo apt install -y curl unzip
      elif [[ "$DISTRO" == "amzn" || "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
        sudo yum update -y
        sudo yum install -y curl unzip
      else
        echo "❌ Unsupported Linux distribution: $DISTRO"
        exit 1
      fi
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install   #install awscli
      aws --version
      rm -rf awscliv2.zip aws
   elif [[ "$OS" == "Darwin" ]]; then
      # macOS
      if ! command -v brew &>/dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first: https://brew.sh"
        exit 1
      fi
      brew install awscli
   else
      echo "❌ Unsupported operating system: $OS"
      echo "If you are on a windows machine run this command in powershell: msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi, then restart your code editor"
      exit 1
   fi
   rm -rf awscliv2.zip aws
   echo ""
   echo "============================"
   echo "✅ AWS CLI installed successfully!"
   echo "============================"
fi

echo "Let's check if you've configured aws-cli"
if aws sts get-caller-identity &>/dev/null; then
   echo "✅ AWS CLI is already configured."
   aws sts get-caller-identity
   read -p "Do you want to reconfigure?(yes/no): " CHOICE
   if [[ "$CHOICE" == "yes" ]]; then
      echo "Let's reconfigure!!"
   else 
      echo "Setup Complete!."
      exit 0
   fi
else
   echo "⚠️ AWS CLI is not configured. Let's configure!"
fi
#take input for secret and access key
while true; do
read -p "Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
read -p "Enter your AWS Default Region (e.g., us-east-1): " AWS_DEFAULT_REGION
read -p "Enter your AWS output format (json, table, text): " AWS_OUTPUT_FORMAT
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_DEFAULT_REGION"
aws configure set output "$AWS_OUTPUT_FORMAT"

echo "🧪 Verifying credentials..."
  if aws sts get-caller-identity &>/dev/null; then
      break
    else
      echo "❌ Invalid AWS credentials."
      read -p "Do you want to retry? (yes/no): " choice
      if [[ "$choice" != "yes" ]]; then
        echo "Exiting setup."
        exit 1
      fi
    fi
  done

echo ""
echo "============================"
echo "✅ AWS CLI configured successfully!"
echo "============================"
aws sts get-caller-identity
