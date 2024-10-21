#!/bin/bash

# Add VMs IP to known host
# ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "192.168.122.101"
# nano ~/.ssh/config
# Host 192.168.122.*
#    StrictHostKeyChecking accept-new
#    UserKnownHostsFile /dev/null

# Check for hardware virtualization support
if [ $(egrep -c '(vmx|svm)' /proc/cpuinfo) -eq 0 ]; then
    echo "Error: CPU doesn't support hardware virtualization."
    exit 1
else
    echo "CPU supports VMs."
fi

# Update and install KVM/libvirt packages
sudo apt update
sudo apt install -y cpu-checker bridge-utils libvirt-clients libvirt-daemon virt-manager virtinst qemu qemu-kvm

# Start and enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl is-active libvirtd

# Add user to libvirt and kvm groups
CURRENT_USER=$(whoami)
sudo usermod -aG libvirt $CURRENT_USER
sudo usermod -aG kvm $CURRENT_USER

# Install Terraform
wget https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
sudo apt install -y unzip
unzip terraform_0.13.3_linux_amd64.zip
rm terraform_0.13.3_linux_amd64.zip
sudo mv terraform /usr/bin

# Optional: Enable virt-manager for virtual management
# sudo chown $CURRENT_USER:$CURRENT_USER /var/run/libvirt/libvirt-sock

# Install Terraform libvirt provider
mkdir -p ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64
cd /tmp/
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz
tar -xvf terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz
mv ./terraform-provider-libvirt ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64/

# Set security_driver to "none" in qemu.conf
sudo sed -i 's/#security_driver = "selinux"/security_driver = "none"/' /etc/libvirt/qemu.conf
sudo systemctl restart libvirtd

# Ansible

# Storing data

echo "Installation complete!"
