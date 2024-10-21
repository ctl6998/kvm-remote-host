#!/bin/bash


########################
#                      #
# Initialize terrafomr#
#			#
########################
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


#####################################################################################################
echo "Sleep for waiting initialization of VMs"
sleep 20  # Sleep for 20 seconds
#####################################################################################################

########################
#                      #
# Run Ansbile-playbooks#
#			#
########################

cd ansible/




ansible-playbook -i inventory/inventory.ini playbooks/playbook_install/setup.yml -u ubuntu --private-key ~/.ssh/id_rsa
ansible-playbook -i inventory/inventory.ini playbooks/playbook_install/spork_run.yml -u ubuntu --private-key ~/.ssh/id_rsa

echo "Copying"
scp spark_files/chmod.sh spark_files/copy.sh spark_files/filesample.txt spark_files/run.sh spark_files/stop.sh spark_files/WordCount.java spark_files/Count.java spark_files/generate.sh spark_files/start.sh spark_files/comp.sh ubuntu@192.168.122.100:/home/ubuntu/
echo "Copy finished"

ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/first_step.yml 
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/chmod_accept.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_compsh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_startsh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_generatesh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_copysh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_runsh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_stopsh.yml

#####################################################################################################
sleep 10  # Sleep for 10 seconds
#####################################################################################################

########################
#                      #
#    Copy output to    #
#     control node	#
########################

scp -r ubuntu@192.168.122.100:/home/ubuntu/output_SparkWC /home/ubuntu/kvm-remote-host




#####################################################################################################
sleep 10  # Sleep for 10 seconds
#####################################################################################################


########################
#                      #
#    End terraform     #
#              	#
########################

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

################################################END##################################################

echo "PROJECT COMPLETED"


