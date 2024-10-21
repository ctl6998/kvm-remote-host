#!/bin/bash

# Enable error checking
set -e

# Function to display error messages and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if the script is run from the correct directory
if [[ $(basename "$PWD") != "kvm-remote-host" ]]; then
    error_exit "This script must be run from the kvm-remote-host directory."
fi

# Check if the number of slave VMs is provided
if [ $# -eq 0 ]; then
    error_exit "Usage: $0 <number_of_slave_vms>"
fi

# Number of slave VMs
SLAVE_VMS=$1

# Total VMs (including master)
TOTAL_VMS=$((SLAVE_VMS + 1))

# Set the inventory file location
HOSTS_FILE="ansible/inventory/inventory.ini"

# Generate IP list
IP_LIST="["
for i in $(seq 0 $((TOTAL_VMS - 1))); do
    IP="192.168.122.$((100 + i))"
    IP_LIST+="\"$IP\","
done
IP_LIST="${IP_LIST%,}]"

# Run Terraform
(
    cd terraform || error_exit "Failed to change directory to terraform"
    
    echo "Initializing Terraform..."
    terraform init || error_exit "Terraform initialization failed"
    
    echo "Applying Terraform configuration..."
    terraform apply -auto-approve -var="vm_num=$TOTAL_VMS" -var="vm_ips=$IP_LIST" || error_exit "Terraform apply failed"
    
    echo "Debug: Terraform outputs"
    terraform output
    
    # Get IP addresses
    IPS=$(terraform output -json ips | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"' | sed 's/"//g')
    
    echo "Debug: Raw IP addresses"
    echo "$IPS"
    
    # Create inventory file
    echo "[master]" > "../$HOSTS_FILE"
    MASTER_IP=$(echo "$IPS" | head -n 1)
    echo "master ansible_host=$MASTER_IP ansible_user=ubuntu" >> "../$HOSTS_FILE"
    echo "[slaves]" >> "../$HOSTS_FILE"
    
    SLAVE_COUNT=1
    echo "$IPS" | tail -n +2 | while read -r IP; do
        echo "slave$SLAVE_COUNT ansible_host=$IP ansible_user=ubuntu" >> "../$HOSTS_FILE"
        SLAVE_COUNT=$((SLAVE_COUNT + 1))
    done
    
    echo "Generated inventory file:"
    cat "../$HOSTS_FILE"
)

echo "Provisioning with Terraform completed. Inventory file for Ansible has been created at $HOSTS_FILE"
