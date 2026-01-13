#!/usr/bin/env bash

#This script creates terraform.tfvars file with required variable values assigned as given by the user
#Run this script before terraform apply

set -euo pipefail

echo "$(date) Gathering required Terraform variables to generate terraform.tfvars file..."

read -rp "AWS Region (e.g. us-east-1): " REGION
read -rp "Instance type (t2.micro / t3.micro): " INSTANCE_TYPE

MY_IP=$(curl -s https://api.ipify.org)

cat <<EOF > terraform.tfvars
region        = "${REGION}"
instance_type = "${INSTANCE_TYPE}"
myIP          = "${MY_IP}/32"
public_key    = "$(cat ~/.ssh/id_rsa.pub)"
EOF

echo "$(date) terraform.tfvars generated successfully"
