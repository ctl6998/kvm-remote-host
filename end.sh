#!/bin/bash

# Enable error checking
set -e

# Check if the script is run from the correct directory
if [[ $(basename "$PWD") != "kvm-remote-host" ]]; then
    echo "Error: This script must be run from the kvm-remote-host directory."
    exit 1
fi

# Set the hosts.ini file location
HOSTS_FILE="ansible/inventory/inventory.ini"

# Confirm before destroying
read -p "Are you sure you want to destroy all resources? This action cannot be undone. (y/n) " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

# Terraform
(
    cd terraform || exit
    echo "Destroying Terraform-managed resources..."
    terraform destroy -auto-approve
)

# Check if hosts.ini exists and remove it
if [ -f "$HOSTS_FILE" ]; then
    echo "Removing inventory file..."
    rm "$HOSTS_FILE"
fi

echo "Destruction complete. All resources have been removed."
