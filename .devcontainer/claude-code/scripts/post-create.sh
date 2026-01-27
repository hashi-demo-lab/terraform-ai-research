#!/bin/bash
# Post-create setup script for Claude Code devcontainer
set -e

echo "=== Post-Create Setup Starting ==="

# Configure Terraform credentials for HCP Terraform
echo "Configuring Terraform credentials..."
mkdir -p ~/.terraform.d
cat > ~/.terraform.d/credentials.tfrc.json << EOF
{
  "credentials": {
    "app.terraform.io": {
      "token": "${TFE_TOKEN}"
    }
  }
}
EOF
echo "Terraform credentials configured"

echo "=== Post-Create Setup Complete ==="
