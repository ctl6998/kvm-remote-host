#!/bin/bash


#KVM start


cd ansible/




ansible-playbook -i inventory/inventory.ini playbooks/playbook_install/setup.yml -u ubuntu --private-key ~/.ssh/id_rsa
ansible-playbook -i inventory/inventory.ini playbooks/playbook_install/spork_run.yml -u ubuntu --private-key ~/.ssh/id_rsa

echo "Copying"
scp spark_files/chmod.sh spark_files/copy.sh spark_files/filesample.txt spark_files/run.sh spark_files/stop.sh spark_files/WordCount.java spark_files/Count.java spark_files/generate.sh spark_files/start.sh spark_files/comp.sh ubuntu@192.168.122.100:/home/ubuntu/
echo "Copy finished"

ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/first_step.yml 
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/chmod_accept.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_compsh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_copy.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_startsh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_generatesh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_runsh.yml
ansible-playbook -i inventory/inventory.ini playbooks/playbooks_spark/spark_stopsh.yml

