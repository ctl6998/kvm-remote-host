# Distributed Computing Project

## Group Information
**Group 2:**
- Le Chi Thanh
- Nguyen Ngoc Hai 
- Nguyen Thanh Do

## How to Run

### Clone the project:
```
git clone https://github.com/ctl6998/ProjectInfrastructure.git
```

### Install environment packages:
```
./script/install.sh 
```

### Run bash script:
```
start.sh <Number of slave> <Jar file> <Data file>
```

#### Parameter Explanation:
- **Number of slave**: Number of slave VMs to provision. Terraform will create the exact number + 1 VMs (for the master). Each will be Ubuntu 22.04 with 1 CPU core, 20GB storage.
- **Data file**: The data file (.txt) to process
- **Jar file**: The compiled Java package to run

## Script Processing:

1. Provisions (number of slave + 1) VMs with Terraform. IP for master is 192.168.122.100, incrementing for each slave.
2. Returns IPs to Ansible inventory's format: `/ansible/inventory/inventory.ini`
3. Deploys Java, Hadoop, Spark from hosting server to all virtual machines
4. Transfers files to the master, compiles and packages the Java file if needed.
5. Deploys the Hadoop file system and uploads the data file to `hdfs://input/<data_file>`.
6. Initiates Spark and executes the application across the Spark cluster.
7. Merges the output into a single file and downloads it to the local machine.
8. Deprovisions all VMs.

## Output

The result is saved in the `/output` directory.

Checklist:

Ansible require input?
Ansible require environemnt in script/install
